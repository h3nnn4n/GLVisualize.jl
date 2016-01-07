using GLVisualize, FileIO, Colors, GeometryTypes, GLAbstraction
window, renderloop = glscreen()
obj = load(Pkg.dir("GLVisualize","examples", "cat.obj"))
obj_vizz 	 = visualize(obj, color=RGBA{Float32}(0,0,0,0.1))
point3d_vizz = visualize(vertices(obj), scale=Vec3f0(0.01))
axis 		 = visualize(boundingbox(point3d_vizz).value, :grid)
view(obj_vizz)
view(point3d_vizz)
view(axis)
@async renderloop()
yield()
screenshot(window, path="color.png",channel=:color)
screenshot(window, path="depth.png",channel=:depth)
