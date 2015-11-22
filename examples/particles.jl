using GLVisualize, GeometryTypes, GLAbstraction, Colors, Reactive, FileIO
msh = GLNormalMesh(load("cat.obj"))
w,r = glscreen()
a = GLNormalMesh(Sphere{Float32}(Vec3f0(0), 1f0), 32)

function scale_gen(v0, nv)
	l = length(v0)
	for i=1:l
		v0[i] = Vec3f0(1,1,sin((nv*l)/i)+rand(0.00f0:0.001f0:Float32(i/l)))/7f0
	end
	v0
end
function color_gen(v0, nv)
	l = length(v0)
	for x=1:l
		v0[x] = RGBA{U8}(x/l,nv,(sin(x/l/3)+1)/2.,1.)
	end
	v0
end
ps 			 = a.vertices
scale_start  = Vec3f0[Vec3f0(1,1,rand()) for i=1:length(ps)]
scale_signal = foldp(scale_gen, scale_start, bounce(0.1f0:0.02f0:1.0f0))
scale 		 = scale_signal

color_signal = foldp(color_gen, zeros(RGBA{U8}, length(ps)), bounce(0.00f0:0.02f0:1.0f0))
color 		= color_signal


rotation 	= -a.normals

X = visualize((msh, ps), scale=scale, color=color, rotation=rotation)

view(X)
r()

w,r = glscreen()

view(visualize((msh, ps)))
r()