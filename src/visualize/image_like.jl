visualize_default{T <: Colorant}(image::MatTypes{T}, s::Style, data) = @gen_defaults! data begin
    primitive ::GLUVMesh2D   = Rectangle{Float32}(0,0,size(image)...)
    preferred_camera 	     = :orthographic_pixel
    boundingbox 		     = GLBoundingBox(primitive)
end

inner_visualize{T <: Colorant}(img::Texture{T, 2}, s::Style, data::Dict) = assemble_shader(
    img, data,
    "uv_vert.vert", "texture.frag",
    boundingbox=Signal(AABB{Float32}(Vec3f0(0), Vec3f0(size(img)...,0)))
)

_default{T <: Intensity}(main::MatTypes{T}, s::Style, data::Dict) = @gen_defaults! data begin
    intensity        = main
    color            = default(Vector{RGBA{U8}},s)
    primitive        = Rectangle{Float32}(0,0,size(main)...) :: (GeometryPrimitive => GLUVMesh2D,)
    color_norm	     = Vec2f0(0, 1)
    preferred_camera = :orthographic_pixel
    boundingbox 	 = GLBoundingBox(primitive)
    shader           = ("uv_vert.vert", "intensity.frag")
end

_default{T <: AbstractFloat}(main::MatTypes{T}, ::style"distancefield", data) = @gen_defaults! data begin
    distancefield       = main
    color               = default(RGBA, s),
    primitive           = Rectangle{Float32}(0f0,0f0, size(distancefield)...) :: GLUVMesh2D
    
    preferred_camera    = :orthographic_pixel
    shader              = ("uv_vert.vert", "distance_shape.frag")
))

_default{T <: Colorant}(main::MatTypes{T}, ::Style, data) = @gen_defaults! data begin
    image            = main
    primitive        = Rectangle(0f0, 0f0, 40f0, 180f0) :: GLUVMesh2D
    boundingbox      = GLBoundingBox(primitive)
    preferred_camera = :orthographic_pixel
    shader           = ("uv_vert.vert", "texture.frag")
end
