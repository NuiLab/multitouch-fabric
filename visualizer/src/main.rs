extern crate serial;
extern crate cpal;

#[macro_use]
extern crate vulkano;
extern crate winit;
extern crate vulkano_win;

use vulkano::instance::Instance;
use vulkano::device::Device;
use vulkano::swapchain::{Swapchain, SurfaceTransform};
use vulkano::buffer::{BufferUsage, CpuAccessibleBuffer};
use vulkano::pipeline::{GraphicsPipeline, GraphicsPipelineParams};
use vulkano_win::VkSurfaceBuild;

fn main() {
    println!("👗🌋 Vulkan Multitouch Frabric Visualizer Version 0.1.0");

    // Vulkan Instance
    let instance = {
        let extensions = vulkano_win::required_extensions();
        Instance::new(None, &extensions, None).expect("failed to create Vulkan instance")
    };

    // Physical Device
    let physical = vulkano::instance::PhysicalDevice::enumerate(&instance)
        .next()
        .expect("no device available");

    // OS Window
    let window = winit::WindowBuilder::new()
        .build_vk_surface(&instance)
        .unwrap();

    // Graphics Queue Supported
    let queue = physical.queue_families()
        .find(|q| q.supports_graphics() && window.surface().is_supported(q).unwrap_or(false))
        .expect("couldn't find a graphical queue family");

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
        }
        impl_vertex!(Vertex, position);

        CpuAccessibleBuffer::from_iter(&device,
                                       &BufferUsage::all(),
                                       Some(queue.family()),
                                       [Vertex { position: [-0.5, -0.25] },
                                        Vertex { position: [0.0, 0.5] },
                                        Vertex { position: [0.25, -0.1] }]
                                               .iter()
                                               .cloned())
                .expect("failed to create buffer")
    };

    // Shaders
    mod vs {
        include!{"shaders/vert.glsl"}
    }

    let vs = vs::Shader::load(&device).expect("failed to create shader module");

    mod fs {
        include!{"shaders/frag.glsl"}
    }

    let fs = fs::Shader::load(&device).expect("failed to create shader module");

}

