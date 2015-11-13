immutable GLPoints end # only for dispatch 
immutable DistanceField end # only for dispatch 


typealias P_Primitive                     Union{VecTypes{Sprite}, AbstractMesh, GLPoints, DistanceField, Sprite}
typealias P_Position{N, T}                Union{VecTypes{Point{N, T}}, Grid, Cube, Nothing}
typealias P_Scale{N,T}                    Union{VecTypes{Vec{N, T}}, Vec{N, T}, T, Nothing}
typealias P_Rotation{T <: Q.Quaternion}   Union{VecTypes{T}, T, Nothing} # rotation is optional (nothing)
typealias P_Color{T <: Colorant}          Union{VecTypes{T}, T, Nothing}
typealias P_Intensitiy{T <:AbstractFloat} Union{VecTypes{T}, T, Nothing}

type Particle{PR <: P_Primitive, POS <: P_Position, SCALE <: P_Scale, ROT <: P_Rotation, C <: P_Color, I <: P_Intensitiy}
    primitive ::PR
    position  ::POS
    scale     ::SCALE
    rotation  ::ROT
    color     ::C
    intensity ::I
    color_norm::Vec2f0
end

#A few Particle combinations are not supported. We deal with it by defining error constructors
Particle(p::GLPoints, positions, scale::Vec, rotation::Nothing, color, intensity, color_norm) = Particle(p,positions,scale,rotation,color,intensity,color_norm)
Particle(p::GLPoints, positions, scale, rotation, color, intensity, color_norm) = throw(NotSupported("Rotation must be Nothing and scale must be scalar Vec{N}"))

immutable Grid{N, T <: Range}
    dims::NTuple{N, T}
end
Grid(ranges::Range...) = Grid(ranges)

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
        primitive,
        position,
        scale,
        rotation,
        color,
        intensity,
        color_norm
    )
end

Particle{T <: Vec3}(rotation::VecTypes{T},    primitive=Pyramidf0(), data)   = Particle(data, primitive=primitive, rotation=rotation)
Particle{T <: Point3}(positions::VecTypes{T}, primitive=Cubef0(), data)      = Particle(data, primitive=primitive, position=positions)
Particle{T <: Point2}(positions::VecTypes{T}, primitive=DistanceField, data) = Particle(data, primitive=primitive, position=positions)


Particle(data::Dict; kw_args...) = Particle(;kw_args..., [(key, data[key]) for key in fieldnames(Particle)]...)

visualize(p::P_Position, s::Style, data::Dict) = _visualize(Particle(p, data), s, data)
visualize(p::Tuple{P_Position, P_Primitive}, s::Style, data::Dict) = _visualize(Particle(p..., data), s, data)


_visualize{P <: AbstractMesh}(p::Particles{P}, s::Style, data::Dict) = assemble_shader(
    p, data,
    "util.vert", "particles.vert", "standard.frag",
)


_visualize{P <: GLPoints}(p::Particles{P}, s::Style, data::Dict) = assemble_shader(
    p, data,
    "dots.vert", "dots.frag"
)

function _visualize{P <: DistanceField}(p::Particles{P}, s::Style, data::Dict)
    robj = assemble_shader(
        p, data,
        "util.vert", "particles.vert", "distance_shape.frag",
    )
    empty!(robj.prerenderfunctions)
    prerender!(robj,
        glDisable, GL_DEPTH_TEST,
        glDepthMask, GL_FALSE,
        glDisable, GL_CULL_FACE,
        enabletransparency
    )
    robj
end