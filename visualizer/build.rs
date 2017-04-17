extern crate vulkano_shaders;

fn main() {
    // Compiling shaders to SPIR-V
    vulkano_shaders::build_glsl_shaders([("src/shaders/vert.glsl",
                                          vulkano_shaders::ShaderType::Vertex),
                                         ("src/shaders/frag.glsl",
                                          vulkano_shaders::ShaderType::Fragment)]
                                                .iter()
                                                .cloned());
}