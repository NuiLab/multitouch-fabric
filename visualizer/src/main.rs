extern crate serial;
extern crate cpal;

#[macro_use]
extern crate vulkano;
extern crate winit;
extern crate vulkano_win;

use std::sync::Arc;
use std::time::Duration;

use vulkano::instance::Instance;
use vulkano::device::Device;
use vulkano::swapchain::{Swapchain, SurfaceTransform};
use vulkano::buffer::{BufferUsage, CpuAccessibleBuffer};
use vulkano::pipeline::{GraphicsPipeline, GraphicsPipelineParams};
use vulkano::pipeline::blend::Blend;
use vulkano::pipeline::depth_stencil::DepthStencil;
use vulkano::pipeline::input_assembly::InputAssembly;
use vulkano::pipeline::vertex::SingleBufferDefinition;
use vulkano::pipeline::multisample::Multisample;
use vulkano::pipeline::viewport::{ViewportsState, Viewport, Scissor};
use vulkano::descriptor::pipeline_layout::EmptyPipeline;
use vulkano::framebuffer::{Framebuffer, Subpass};
use vulkano::command_buffer;
use vulkano::command_buffer::DynamicState;
use vulkano::command_buffer::PrimaryCommandBufferBuilder;
use vulkano::command_buffer::Submission;
use vulkano_win::VkSurfaceBuild;

fn main() {
    println!("👗🌋 Vulkan Multitouch Frabric Visualizer | Version 0.1.0");

    // Vulkan Instance
    let instance = {
        let extensions = vulkano_win::required_extensions();
        Instance::new(None, &extensions, None)
        .expect("failed to create Vulkan instance")
    };

    // Physical Device
    let physical = vulkano::instance::PhysicalDevice::enumerate(&instance)
        .next()
        .expect("no vulkan device is available, do you have Vulkan installed on your machine?\nVisit https://vulkan.lunarg.com/ and download the latest Vulkan SDK.");

    // OS Window
    let window = winit::WindowBuilder::new()
        .build_vk_surface(&instance)
        .unwrap();

    // Graphics Queue Supported
    let queue = physical.queue_families()
        .find(|q| q.supports_graphics() && window.surface().is_supported(q).unwrap_or(false))
        .expect("Couldn't find a graphical queue family.");

    // Logical Device, Queues
    let (device, mut queues) = {
        let device_ext = vulkano::device::DeviceExtensions {
            khr_swapchain: true,
            ..vulkano::device::DeviceExtensions::none()
        };

        Device::new(&physical,
                    physical.supported_features(),
                    &device_ext,
                    [(queue, 0.5)].iter().cloned())
                .expect("failed to create device")
    };

    // Device Queue
    let queue = queues.next().unwrap();

    // Swapchain, Swapchain Images
    let (swapchain, images) = {

        let caps = window.surface()
            .get_capabilities(&physical)
            .expect("failed to get surface capabilities");

        let dimensions = caps.current_extent.unwrap_or([1280, 720]);

        let present = caps.present_modes.iter().next().unwrap();

        let alpha = caps.supported_composite_alpha.iter().next().unwrap();

        let format = caps.supported_formats[0].0;

        Swapchain::new(&device,
                       &window.surface(),
                       caps.min_image_count,
                       format,
                       dimensions,
                       1,
                       &caps.supported_usage_flags,
                       &queue,
                       SurfaceTransform::Identity,
                       alpha,
                       present,
                       true,
                       None)
                .expect("failed to create swapchain")
    };

    // VBO
    let vertex_buffer = {
        #[derive(Debug, Clone)]
        struct Vertex {
            position: [f32; 2],
            uv: [f32; 2]
        }
        impl_vertex!(Vertex, position, uv);

        CpuAccessibleBuffer::from_iter(&device,
                                       &BufferUsage::all(),
                                       Some(queue.family()),
                                       [Vertex { position: [1.0, -1.0], uv: [1.0, 1.0] },
                                        Vertex { position: [-1.0, -1.0], uv: [0.0, 1.0] },
                                        Vertex { position: [1.0, 1.0], uv: [1.0, 0.0] },
                                         Vertex { position: [-1.0, 1.0], uv: [0.0, 0.0] }]
                                               .iter()
                                               .cloned())
                .expect("failed to create buffer")
    };

    // Shaders
    mod vs {
        include!{concat!(env!("OUT_DIR"), "/shaders/src/shaders/vert.glsl")}
    }

    let vs = vs::Shader::load(&device).expect("failed to create shader module");

    mod fs {
        include!{concat!(env!("OUT_DIR"), "/shaders/src/shaders/frag.glsl")}
    }

    let fs = fs::Shader::load(&device).expect("failed to create shader module");

    // Render Pass
    mod render_pass {

        use vulkano::format::Format;

        single_pass_renderpass!{
            attachments: {
                color: {
                    load: Clear,
                    store: Store,
                    format: Format,
                }
            },
            pass: {
                color: [color],
                depth_stencil: {}
            }
        }
    }

    let render_pass =
        render_pass::CustomRenderPass::new(&device,
                                           &render_pass::Formats {
                                                // Use the format of the images and one sample.
                                                color: (images[0].format(), 1),
                                            })
                .unwrap();

    // Graphics Pipeline
    let pipeline = GraphicsPipeline::new(&device,
                                         GraphicsPipelineParams {
                                             vertex_input: SingleBufferDefinition::new(),

                                             vertex_shader: vs.main_entry_point(),

                                             input_assembly: InputAssembly::triangle_list(),

                                             tessellation: None,

                                             geometry_shader: None,

                                             viewport: ViewportsState::Fixed {
                                                 data: vec![(Viewport {
                                                                 origin: [0.0, 0.0],
                                                                 depth_range: 0.0..1.0,
                                                                 dimensions:
                                                                     [images[0].dimensions()[0] as
                                                                      f32,
                                                                      images[0].dimensions()[1] as
                                                                      f32],
                                                             },
                                                             Scissor::irrelevant())],
                                             },

                                             raster: Default::default(),

                                             multisample: Multisample::disabled(),

                                             fragment_shader: fs.main_entry_point(),

                                             depth_stencil: DepthStencil::disabled(),

                                             blend: Blend::pass_through(),

                                             layout: &EmptyPipeline::new(&device).unwrap(),

                                             render_pass: Subpass::from(&render_pass, 0).unwrap(),
                                         })
            .unwrap();

    let framebuffers = images.iter()
        .map(|image| {
            let dimensions = [image.dimensions()[0], image.dimensions()[1], 1];
            Framebuffer::new(&render_pass,
                             dimensions,
                             render_pass::AList { color: image })
                    .unwrap()
        })
        .collect::<Vec<_>>();

    let mut submissions: Vec<Arc<Submission>> = Vec::new();

    loop {

        submissions.retain(|s| s.destroying_would_block());

        let image_num = swapchain.acquire_next_image(Duration::new(1, 0)).unwrap();

        let command_buffer = PrimaryCommandBufferBuilder::new(&device, queue.family())
            .draw_inline(&render_pass,
                         &framebuffers[image_num],
                         render_pass::ClearValues { color: [0.0, 0.0, 1.0, 1.0] })
            .draw(&pipeline, &vertex_buffer, &DynamicState::none(), (), &())
            .draw_end()
            .build();


        submissions.push(command_buffer::submit(&command_buffer, &queue).unwrap());


        swapchain.present(&queue, image_num).unwrap();


        for ev in window.window().poll_events() {
            match ev {
                winit::Event::Closed => return,
                _ => (),
            }
        }
    }
}

