_default{T <: Point}(position::VecTypes{T}, s::style"lines", data) = @gen_defaults! data begin
    dotted              = false
    vertex              = position               :: (Vector => GLBuffer,)
    color               = default(RGBA, s, 1)    :: (Vector => GLBuffer,)
    stroke_color        = default(RGBA, s, 2)    :: (Vector => GLBuffer,)
    if dotted
        lastlen         = const_lift(lastlen, x) :: (Vector => GLBuffer,)
        maxlength       = const_lift(last, ll)
    end
    thickness           = 2f0
    shape               = RECTANGLE
    style               = FILLED
    transparent_picking = false
    preferred_camera    = :orthographic_pixel
    max_primitives      = length(position)-4
    boundingbox         = GLBoundingBox(position)
    shader              = ("util.vert", "lines.vert", "lines.geom", "lines.frag")
    gl_primitive        = GL_LINE_STRIP_ADJACENCY
end

function lastlen(points)
    result = zeros(eltype(points[1]), length(points))
    for i=1:length(points)
        i0 = max(i-1,1)
        result[i] = result[i0] + norm(points[i0]-points[i])
    end
    result
end

function _default{T <: AbstractFloat}(positions::Vector{T}, range::Range, s::style"lines", data)
    length(positions) != length(range) && throw(
        DimensionMismatsch("length of $(typeof(positions)) $(length(positions)) and $(typeof(range)) $(length(range)) must match")
    )
    _default(points2f0(positions, range), s, data)
end

#Parametric rendering of arbitrary opengl functions
_default(func::Shader, s::Style, data) = @gen_defaults! data begin
    primitive        = Rectangle{Float32}(0f0,0f0,1f0,1f0) :: GLUVMesh2D
    color            = default(RGBA, s),
    boundingbox      = GLBoundingBox(primitive)
    preferred_camera = :orthographic_pixel
    shader           = ("parametric.vert", "parametric.frag", (view => Dict("function" => bytestring(func.source))))
end