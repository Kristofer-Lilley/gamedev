@tool
extends MeshInstance3D

const SIZE := 256.0

@export_range(4, 256, 4) var resolution := 32
@export var noise: FastNoiseLite
@export_range(4.0, 128.0) var height := 64.0

func _ready() -> void:
	generate_mesh()


func generate_mesh() -> void:
	if not noise:
		noise = FastNoiseLite.new()
		noise.frequency = 0.008
	
	var plane := PlaneMesh.new()
	plane.size = Vector2(SIZE, SIZE)
	plane.subdivide_width = resolution
	plane.subdivide_depth = resolution
	
	var arrays := plane.get_mesh_arrays()
	var verts: PackedVector3Array = arrays[ArrayMesh.ARRAY_VERTEX]
	var norms: PackedVector3Array = arrays[ArrayMesh.ARRAY_NORMAL]
	var tangs: PackedFloat32Array = arrays[ArrayMesh.ARRAY_TANGENT]
	
	for i in verts.size():
		var v = verts[i]
		v.y = noise.get_noise_2d(v.x * 0.1, v.z * 0.1) * height
		
		# Very basic normal
		norms[i] = Vector3.UP
		
		verts[i] = v
		
		# Tangent
		tangs[4*i] = 1.0
		tangs[4*i+1] = 0.0
		tangs[4*i+2] = 0.0
		tangs[4*i+3] = 1.0
	
	var new_mesh = ArrayMesh.new()
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh = new_mesh
	
	print("✅ Mesh generated! Size = ", SIZE, " | Resolution = ", resolution, " | Vertices = ", verts.size())
