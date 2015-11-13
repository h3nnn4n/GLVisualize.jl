function overall_scale(stroke_width, glow_width, scale, style)
    final_scale = Vec2f0(scale)
    style|OUTLINED && (final_scale += stroke_width/2f0)
    style|GLOWING  && (final_scale += glow_width/2f0)
    final_scale
end

function _default{T <: Point{2}}(::VecTypes{T}, s::Style, kw_args=Dict())
    @gen_defaults! kw_args begin
        scale               = 1f0
        stroke_width        = 4f0
        glow_width          = 4f0
        style               = OUTLINED|FILLED
        offset_scale        = const_lift(overall_scale, stroke_width, glow_width, scale, style)
        primitive           = Rectangle(-0.5f0, -0.5f0, 1f0, 1f0)
        shape               = RECTANGLE
        transparent_picking = true
        color               = default(RGBA, s)
        stroke_color        = default(RGBA, s, 2)
        glow_color          = default(RGBA, s, 3)
        preferred_camera    = :orthographic_pixel
    end
end


function _visualize{T <: Point{2}}(particle::TextureBuffer{T, 1}, s::Style, data::Dict)
    robj = assemble_shader(
        positions, data,
        "util.vert", "particles2D.vert", "distance_shape.frag",
    )
    
end
