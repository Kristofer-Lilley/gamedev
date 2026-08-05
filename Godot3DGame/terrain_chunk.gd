@tool
extends MeshInstance3D

const SIZE := 256.0

var chunk_x := 0
var chunk_z := 0
var noise: FastNoiseLite
var resolution := 32
var height := 120.0   # increased

func generate(x: int, z: int, noise_ref: FastNoiseLite, res: int = 32, h: float = 120.0):
	chunk_x = x
	chunk_z = z
	noise = noise_ref
	resolution = res
	height = h
	_create_mesh()

func _create_mesh():
	if not noise:
		push_error("Noise missing!")
		return
	
	var plane = PlaneMesh.new()
	plane.size = Vector2(SIZE, SIZE)
	plane.subdivide_width = resolution
	plane.subdivide_depth = resolution
	
	var arrays = plane.get_mesh_arrays()
	var verts: PackedVector3Array = arrays[ArrayMesh.ARRAY_VERTEX]
	
	var max_height = 0.0
	
	for i in verts.size():
		var v: Vector3 = verts[i]
		var world_x = (v.x + chunk_x * SIZE) * 0.015   # ← Key value
		var world_z = (v.z + chunk_z * SIZE) * 0.015   # ← Key value
		
		var value = noise.get_noise_2d(world_x, world_z)
		v.y = value * height
		
		if abs(v.y) > max_height:
			max_height = abs(v.y)
		
		verts[i] = v
	
	var new_mesh = ArrayMesh.new()
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh = new_mesh
	
	print("Chunk ", chunk_x, ",", chunk_z, " | Max height reached: ", max_height)
