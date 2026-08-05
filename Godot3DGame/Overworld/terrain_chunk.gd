@tool
extends MeshInstance3D

const SIZE := 256.0

var chunk_x := 0
var chunk_z := 0
var noise: FastNoiseLite
var height := 150.0
var resolution := 32

@export var tree_mesh: Mesh = null
@export var tree_material: Material = null
@export var grass_mesh: Mesh
@export var grass_material: Material

@export var tree_density := 30
@export var grass_density := 10.0

var grass_texture = preload("res://Texture_15_Diffuse2.png")

func generate(x: int, z: int, noise_ref: FastNoiseLite, res: int = 32, h: float = 150.0):
	chunk_x = x
	chunk_z = z
	noise = noise_ref
	resolution = res
	height = h
	
	_create_terrain_mesh()
	
	# Temporary: call directly first
	place_decorations()        # <--- change to this for testing
	# call_deferred("place_decorations")

func _create_terrain_mesh():
	if not noise: return
	
	var plane = PlaneMesh.new()
	plane.size = Vector2(SIZE, SIZE)
	plane.subdivide_width = resolution
	plane.subdivide_depth = resolution
	
	var arrays = plane.get_mesh_arrays()
	var verts: PackedVector3Array = arrays[ArrayMesh.ARRAY_VERTEX]
	
	for i in verts.size():
		var v = verts[i]
		var world_x = (v.x + chunk_x * SIZE) * 0.012
		var world_z = (v.z + chunk_z * SIZE) * 0.012
		
		var n = noise.get_noise_2d(world_x, world_z)
		n = n * 0.6 + noise.get_noise_2d(world_x*3, world_z*3) * 0.3
		v.y = n * height
		verts[i] = v
	
	var new_mesh = ArrayMesh.new()
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	mesh = new_mesh
	
	
	create_trimesh_collision()
	
	_add_ground_textures("woodland_grass", self)

func _add_ground_textures(ground_type: String, mesh_instance: MeshInstance3D) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.8, 0.2)   # Bright green as fallback
	
	if ground_type == "woodland_grass":
		var texture = preload("res://Texture_15_Diffuse2.png") as Texture2D
		if texture:
			material.albedo_texture = texture
			material.uv1_scale = Vector3(10, 1, 10)
		else:
			push_error("Grass texture not found!")
	
	mesh_instance.material_override = material
	

func place_decorations():
	print("=== place_decorations STARTED for chunk ", chunk_x, ",", chunk_z, " ===")
	
	clear_old_decorations()
	
	if not tree_mesh:
		print("ERROR: tree_mesh is null!")
		return
	
	print("tree_mesh OK, density = ", tree_density)
	
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(Vector2i(chunk_x, chunk_z))
	
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = tree_mesh
	
	var target_count = int(SIZE * SIZE * tree_density / 1200.0)
	mm.instance_count = target_count
	print("Target tree count: ", target_count)
	
	var placed = 0
	for i in target_count:
		var local_x = rng.randf_range(-SIZE/2 + 20, SIZE/2 - 20)
		var local_z = rng.randf_range(-SIZE/2 + 20, SIZE/2 - 20)
		
		var world_x = local_x + chunk_x * SIZE
		var world_z = local_z + chunk_z * SIZE
		
		var n = noise.get_noise_2d(world_x * 0.012, world_z * 0.012)
		n = n * 0.6 + noise.get_noise_2d(world_x * 0.036, world_z * 0.036) * 0.3
		var y = n * height + 0.8
		
		var pos = Vector3(local_x, y, local_z)
		
		var t = Transform3D()
		t.origin = pos
		t = t.rotated_local(Vector3.UP, rng.randf_range(0, TAU))
		t = t.scaled(Vector3.ONE * rng.randf_range(0.8, 1.6))
		
		mm.set_instance_transform(i, t)
		placed += 1
	
	print("Successfully placed ", placed, " trees")
	
	var mmi = MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = tree_material
	mmi.name = "MultiTrees"
	add_child(mmi)
	
	print("=== place_decorations FINISHED ===")


func clear_old_decorations():
	for child in get_children():
		if child is MultiMeshInstance3D:
			child.queue_free()
