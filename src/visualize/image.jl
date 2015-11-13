visualize_default{T <: Colorant}(image::Union{Texture{T, 2}, Matrix{T}}, ::Style, kw_args=Dict()) = Dict(
    :primitive        => GLUVMesh2D(Rectangle{Float32}(0f0,0f0,size(image)...)),
    :preferred_camera => :orthographic_pixel
)

_visualize{T <: Colorant}(img::Texture{T, 2}, s::Style, data::Dict) = assemble_shader(
    img, data,
    "uv_vert.vert", "texture.frag",
    boundingbox=Input(AABB{Float32}(Vec3f0(0), Vec3f0(size(img)...,0)))
)
