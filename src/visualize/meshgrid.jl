immutable GLPoints end # only for dispatch 

typealias P_Primitive       Union{GPUArray{Sprite}, Mesh, GLPoints, Sprite}
typealias P_Position{N, T}  Union{GPUArray{Point{N, T}}, Grid, Cube}
typealias P_Scale           Union{GPUArray{Vec{N, T}}, Vec{N, T}}
typealias P_Rotation{T <: Q.Quaternion}   Union{T, GPUArray{T}, Nothing} # rotation is optional (nothing)
typealias P_Color{T <: Colorant}          Union{GPUArray{T}, T}
typealias P_Intensitiy{T <:AbstractFloat} Union{GPUArray{T}, T}

type Particle{PR <: P_Primitive, POS <: P_Position, SCALE <: P_Scale, ROT <: P_Rotation, C <: P_Color, I <: P_Intensitiy}
    primitive ::PR
    position  ::POS
    scale     ::SCALE
    rotation  ::ROT
    color     ::C
    intensity ::I
    color_norm::Vec2f0
end
function Particle(;
        primitive   = GLPoints,
        position    = Grid(-1:1, -1:1),
        scale       = nothing,
        rotation    = nothing,
        color       = nothing,
        intensity   = nothing,
        color_norm  = nothing,
    )
    Particle(
        gl_convert(primitive),
        gl_convert(position),
        gl_convert(scale),
        gl_convert(rotation),
        gl_convert(color),
        gl_convert(intensity),
        gl_convert(color_norm)
    )
end

Particle(data::Dict; kw_args...) = Particle(;kw_args..., [(key, data[key]) for key in fieldnames(Particle)]...)


function visualize_default{T}(grid::MatTypes{T}, ::Style, kw_args=Dict())
    grid_min = get!(kw_args, :grid_min, Vec2f0(-1, -1))
    grid_max = get!(kw_args, :grid_max, Vec2f0( 1,  1))
    grid_length = grid_max - grid_min
    scale = Vec3f0((1f0 / Vec2f0(size(grid))), 1f0) .* Vec3f0(grid_length, 1f0)
    p = GLNormalMesh(Cube{Float32}(Vec3f0(0), Vec3f0(1.0)))
    n = Vec2f0(minimum(grid), maximum(grid))
    return Dict(
        :primitive  => p,
        :color      => default(Vector{RGBA}),
        :scale      => scale,
        :color_norm => n
    )
end

function visualize{T <: AbstractFloat}(grid::Texture{T, 2}, s::Style, customizations=visualize_default(grid, s))
    @materialize grid_min, grid_max, color_norm = customizations
    data[:y_scale] = grid
    assemble_instanced(
        grid, data,
        "util.vert", "meshgrid.vert", "standard.frag",
        boundingbox=const_lift(particle_grid_bb, grid_min, grid_max, color_norm)
    )
end
