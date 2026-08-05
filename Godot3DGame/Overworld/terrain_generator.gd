@tool
extends Node3D

@export var player: Node3D
@export var view_distance := 2
@export var chunk_resolution := 32
@export var chunk_height := 120.0
@export var noise: FastNoiseLite


var chunks = {}
var chunk_scene = preload("res://Overworld/TerrainChunk.tscn")

const CHUNK_SIZE = 256.0

func _ready():
	print("=== TERRAIN GENERATOR _READY() CALLED ===")
	print("Player assigned: ", player != null)
	
	if not noise:
		noise = FastNoiseLite.new()
		noise.frequency = 0.005
		noise.fractal_octaves = 6
		noise.seed = 12345
		print("✅ Created new noise")
	else:
		print("✅ Using existing noise")
	
	_update_chunks()

func _process(_delta):
	if player:
		_update_chunks()

func _update_chunks():
	if not player:
		print("WARNING: No player assigned!")
		return
	
	var player_x = int(player.global_position.x / CHUNK_SIZE)
	var player_z = int(player.global_position.z / CHUNK_SIZE)
	
	
	var new_chunks = {}
	
	for x in range(player_x - view_distance, player_x + view_distance + 1):
		for z in range(player_z - view_distance, player_z + view_distance + 1):
			var key = Vector2i(x, z)
			if not chunks.has(key):
				_create_chunk(x, z)
			new_chunks[key] = chunks[key]
	
	chunks = new_chunks

func _create_chunk(x: int, z: int):
	print("Spawning chunk at ", x, ",", z)
	var chunk = chunk_scene.instantiate()
	chunk.generate(x, z, noise, chunk_resolution, chunk_height)   # Force call
	chunk.position = Vector3(x * CHUNK_SIZE, 0, z * CHUNK_SIZE)
	add_child(chunk)
	chunks[Vector2i(x, z)] = chunk
