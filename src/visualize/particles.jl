_default{T <: Point3}(main::VecTypes{T}, s::Style, data::Dict) = _default((centered(Cube),      main), s, data)
_default{T <: Point2}(main::VecTypes{T}, s::Style, data::Dict) = _default((centered(Rectangle), main), s, data)
function _default{T <: Vec3}(main::VolumeTypes{T}, s::Style, data::Dict)
    data[:rotation] = main
    grid = Grid(
        linspace(-1f0, 1f0, size(main, 1))
        linspace(-1f0, 1f0, size(main, 2))
        linspace(-1f0, 1f0, size(main, 3))
    )
    _default((Pyramid(Point3f0(0,0,-0.5), 1f0, 0.2f0), grid), s, data)
end

_default{Primitive <: GeometryPrimitive{3}, Position <: Array{Point}}(p::Tuple{Primitive, Position}, s::Style, data) = @gen_defaults! data begin
    primitive        = p[1] :: GLNormalMesh
    color            = default(RGBA{Float32}, s) => TextureBuffer
    position         = p[2]                      => TextureBuffer
    scale            = nothing                   => TextureBuffer
    rotation         = nothing                   => TextureBuffer
    intensity        = nothing                   => TextureBuffer
    color_norm       = nothing                   => TextureBuffer
    boundingbox      = GLBoundingBox(position, scale, primitive)
    shader           = ("util.vert", "particles.vert", "standard.frag")
end

_default{T <: Point}(positions::VectTypes{T}, s::style"points", data) = @gen_defaults! data begin
    vertex       = positions => GLBuffer
    point_size   = 2f0
    prerender    = +((glPointSize, point_size),)
    shader       = ("dots.vert", "dots.frag")
    gl_primitive = GL_POINTS
end


function overall_scale(stroke_width, glow_width, scale, style)
    final_scale = Vec3f0(scale)
    (stroke_width > 0f0) && (final_scale += stroke_width/2f0)
    (glow_width   > 0f0) && (final_scale += glow_width/2f0)
    final_scale
end


primitive_shape(::Circle)    = CIRCLE
primitive_shape(::Rectangle) = RECTANGLE

_default{Primitive <: GeometryPrimitive{2}, Position <: Array{Point}}(p::Tuple{Primitive, Position}, s::Style, data) = @gen_defaults! data begin
    scale               = 1f0
    stroke_width        = 2f0
    glow_width          = 0f0
    offset_scale        = const_lift(overall_scale, stroke_width, glow_width, scale, style)
    shape               = RECTANGLE
    position            = p[2]                => GLBuffer
    color               = default(RGBA, s)    => GLBuffer
    stroke_color        = default(RGBA, s, 2) => GLBuffer
    glow_color          = default(RGBA, s, 3) => GLBuffer
    image               = nothing             => Texture
    distancefield       = nothing             => Texture
    transparent_picking = true
    preferred_camera    = :orthographic_pixel
    shader              = ("util.vert", "billboards.geom", "billboards.vert", "distance_shape.frag")
    gl_primitive        = GL_POINTS
end


_default{T <: Vec{3}}(p::Tuple{Prim, }, s::Style, data) = @gen_defaults! begin
    vectorfield    = vf => Texture(;minfilter=:nearest, x_repeat=:clamp_to_edge)
    primitive      =  :: GLNormalMesh
    boundingbox    = AABB{Float32}(Vec3f0(-1), Vec3f0(1)),
    color_norm     = begin 
        _norm = map(norm, vectorfield)
        Vec2f0(minimum(_norm), maximum(_norm))
    end
    color          = default(Vector{RGBA})
    shader         = ("util.vert", "vectorfield.vert", "standard.frag")
end

