_default(mesh::GLNormalAttributeMesh, s::Style, data::Dict) = @gen_defaults! data begin
    main 		= mesh
    boundingbox = GLBoundingBox(mesh)
    shader 		= GLVisualizeShader("util.vert", "attribute_mesh.vert", "standard.frag")
end

_default(mesh::GLNormalMesh, s::Style, data::Dict) = @gen_defaults! data begin
    main 		= mesh
    color 		= default(RGBA{Float32}, s)
    boundingbox = GLBoundingBox(mesh)
    shader 		= GLVisualizeShader("util.vert", "standard.vert", "standard.frag")
end

_default(main::GLPlainMesh, ::style"grid", data::Dict) = @gen_defaults! data begin
    primitive       = main
    color           = default(RGBA, s, 1)
    bg_colorc       = default(RGBA, s, 2)
    grid_thickness  = Vec3f0(2)
    gridsteps       = Vec3f0(5)
    shader          = GLVisualizeShader("grid.vert", "grid.frag")
    boundingbox     = GLBoundingBox(primitive)
end
#=
empty!(robj.prerenderfunctions)
prerender!(robj,
    glEnable, GL_DEPTH_TEST,
    glDepthMask, GL_FALSE,
    glDepthFunc, GL_LEQUAL,
    glEnable, GL_CULL_FACE,
    glCullFace, GL_BACK,
    enabletransparency
)
=#
