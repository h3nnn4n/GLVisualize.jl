const SELECTION         = Dict{Symbol, Input{Matrix{Vector2{Int}}}}()
const SELECTION_QUERIES = Dict{Symbol, Rectangle{Int}}()

function insert_selectionquery!(name::Symbol, value::Rectangle)
    SELECTION_QUERIES[name] = value
    SELECTION[name]         = Input(Vector2{Int}[]')
    SELECTION[name]
end
function insert_selectionquery!(name::Symbol, value::Signal{Rectangle{Int}})
    lift(value) do v
    SELECTION_QUERIES[name] = v
    end
    SELECTION[name]         = Input(Array(Vector2{Int}, value.value.w, value.value.h))
    SELECTION[name]
end
function delete_selectionquery!(name::Symbol)
    delete!(SELECTION_QUERIES, name)
    delete!(SELECTION, name)
end


windowhints = [
    (GLFW.SAMPLES,      0), 
    (GLFW.DEPTH_BITS,   0), 
    (GLFW.ALPHA_BITS,   0), 
    (GLFW.STENCIL_BITS, 0),
    (GLFW.AUX_BUFFERS,  0)
]

const ROOT_SCREEN = createwindow("Romeo", 1920, 1280, windowhints=windowhints, debugging=true)
const TIMER_SIGNAL = fpswhen(GLVisualize.ROOT_SCREEN.inputs[:open], 30.0)

function fold_loop(v0, timediff_range)
    _, range = timediff_range
    v0 == last(range) && return first(range) 
    v0+step(range)
end

loop(range::Range; t=TIMER_SIGNAL) =
    foldl(fold_loop, first(range), lift(tuple, t, range))


function fold_bounce(v0, v1)
    _, range = v1
    val, direction = v0
    val += step(range)*direction
    if val > last(range) || val < first(range) 
    direction = -direction
    val += step(range)*direction
    end
    (val, direction)
end

bounce{T}(range::Range{T}; t=TIMER_SIGNAL) = 
    lift(first, foldl(fold_bounce, (first(range), one(T)), lift(tuple, t, range)))
    
insert_selectionquery!(:mouse_hover, lift(ROOT_SCREEN.inputs[:mouseposition]) do mpos
    Rectangle{Int}(round(Int, mpos[1]), round(Int, mpos[2]), 1,1)
end)


const FRAME_BUFFER_PARAMETERS = [
    (GL_TEXTURE_WRAP_S,  GL_CLAMP_TO_EDGE),
    (GL_TEXTURE_WRAP_T,  GL_CLAMP_TO_EDGE ),

    (GL_TEXTURE_MIN_FILTER, GL_NEAREST),
    (GL_TEXTURE_MAG_FILTER, GL_NEAREST) 
]

global const RENDER_FRAMEBUFFER = glGenFramebuffers()
glBindFramebuffer(GL_FRAMEBUFFER, RENDER_FRAMEBUFFER)


framebuffsize = [ROOT_SCREEN.inputs[:framebuffer_size].value...]
const COLOR_BUFFER   = Texture(RGBA{Ufixed8},     framebuffsize, parameters=FRAME_BUFFER_PARAMETERS)
const STENCIL_BUFFER = Texture(Vector2{GLushort}, framebuffsize, parameters=FRAME_BUFFER_PARAMETERS)

glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, COLOR_BUFFER.id, 0)
glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, GL_TEXTURE_2D, STENCIL_BUFFER.id, 0)

const rboDepthStencil = GLuint[0]

glGenRenderbuffers(1, rboDepthStencil)
glBindRenderbuffer(GL_RENDERBUFFER, rboDepthStencil[1])
glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT32, framebuffsize...)
glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rboDepthStencil[1])

lift(ROOT_SCREEN.inputs[:framebuffer_size]) do window_size
    if all(x->x>0, window_size)
        resize_nocopy!(COLOR_BUFFER, tuple(window_size...))
        resize_nocopy!(STENCIL_BUFFER, tuple(window_size...))
        glBindRenderbuffer(GL_RENDERBUFFER, rboDepthStencil[1])
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT32, (window_size)...)
    end 
end


postprocess_robj = postprocess(COLOR_BUFFER, ROOT_SCREEN)

function renderloop()
    global ROOT_SCREEN
    while ROOT_SCREEN.inputs[:open].value
        renderloop(ROOT_SCREEN)
    end
    GLFW.Terminate()
    FreeTypeAbstraction.done()
end


function renderloop(screen)
    yield() 
    glDisable(GL_SCISSOR_TEST)
    glBindFramebuffer(GL_FRAMEBUFFER, RENDER_FRAMEBUFFER)
    glDrawBuffers(2, [GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1])
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    render(screen)
    yield() 
    #Read all the selection queries
    if !isempty(SELECTION_QUERIES)
        glReadBuffer(GL_COLOR_ATTACHMENT1)
        for (key, value) in SELECTION_QUERIES
            if value.w < 1 || value.w > 5000
            println(value.w) # debug output
            end
            if value.h < 1 || value.h > 5000
            println(value.h) # debug output
            end
            const data = Array(Vector2{Uint16}, value.w, value.h)
            glReadPixels(value.x, value.y, value.w, value.h, STENCIL_BUFFER.format, STENCIL_BUFFER.pixeltype, data)
            push!(SELECTION[key], convert(Matrix{Vector2{Int}}, data))
        end
    end
    yield() 
    glDisable(GL_SCISSOR_TEST)
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0)
    glViewport(screen.area.value)
    glClear(GL_COLOR_BUFFER_BIT)
    render(postprocess_robj)
    GLFW.SwapBuffers(screen.nativewindow)
    GLFW.PollEvents()
    yield() 
    sleep(0.001)
end

glClearColor(0.09411764705882353,0.24058823529411763,0.2401960784313726, 0)

