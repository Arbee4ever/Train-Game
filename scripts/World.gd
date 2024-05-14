extends Node3D

var noise: TerrainNoise = TerrainNoise.new()
var chunkSize = Vector2i(200, 200)
var loadedChunks: Dictionary  = {}

func _init():
	noise.seed = randi()
	noise.frequency = 0.0025
	noise.noise_type = FastNoiseLite.TYPE_VALUE_CUBIC

	
func generate_chunk():
	var mesh_instance = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(chunkSize.x, chunkSize.y)
	mesh_instance.mesh = plane_mesh
#	TODO: Remove to reenable random terrain generation
	#mesh_instance.create_trimesh_collision()
	#return mesh_instance
	plane_mesh.subdivide_depth = chunkSize.x/10 - 1
	plane_mesh.subdivide_width = chunkSize.y/10 - 1
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	
	var array_plane = surface_tool.commit()
	
	var data_tool = MeshDataTool.new()
	
	data_tool.create_from_surface(array_plane, 0)
	
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		vertex.y = noise.get_noise(Vector2(vertex.x, vertex.z))
		
		data_tool.set_vertex(i, vertex)
	
	array_plane.clear_surfaces()
	
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	mesh_instance.mesh = surface_tool.commit()
	
	mesh_instance.create_trimesh_collision()
	return mesh_instance

func add_chunk(chunkCoords: Vector2):
	if loadedChunks.has(str(chunkCoords)):
		return
	print("Generating chunk ", str(chunkCoords))
	loadedChunks[str(chunkCoords)] = MeshInstance3D.new()
	var realCoords = Vector2(chunkCoords.x * chunkSize.x, chunkCoords.y * chunkSize.y)
	noise.offset = Vector3(realCoords.x, realCoords.y, 0)
	
	var chunk = generate_chunk()
	chunk.position = Vector3(realCoords.x, 0, realCoords.y)
	chunk.get_child(0).input_event.connect(%Builder.build)
	
	var groundMaterial = StandardMaterial3D.new()
	var groundTexture = ImageTexture.create_from_image(noise.get_image(chunkSize.x, chunkSize.y, false, false, false))
	groundMaterial.albedo_texture = groundTexture
	groundMaterial.albedo_color = Color.DARK_GREEN
	groundMaterial.texture_repeat = false
	groundMaterial.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	chunk.material_override = groundMaterial
	
	loadedChunks[str(chunkCoords)] = chunk
	
	var water = MeshInstance3D.new()
	var water_mesh = PlaneMesh.new()
	water_mesh.size = Vector2(chunkSize.x, chunkSize.y)
	water.mesh = water_mesh
	
	var waterMaterial = StandardMaterial3D.new()
	waterMaterial.albedo_color = Color( 0, 0.2, 1, 0.3)
	waterMaterial.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	waterMaterial.texture_repeat = false
	water.material_override = waterMaterial
	chunk.add_child(water)
	add_child(chunk)

#Basic Day/Night Cycle
"""var switch = true
var rate = 0.025
func _process(delta):
	if switch:
		$DirectionalLight3D.light_energy -= rate * delta
	else:
		$DirectionalLight3D.light_energy += rate * delta
	
	if $DirectionalLight3D.light_energy >= 1 || $DirectionalLight3D.light_energy <= 0:
		switch = !switch"""

func _input(event):
	if event.is_action_pressed("toggle_debug_view"):
		%ChunkBorder.visible = !%ChunkBorder.visible
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()

@export var radius = 81;
func _physics_process(delta):
	var currentChunk = Vector2i(round(%Character.position.x/chunkSize.x), round(%Character.position.z/chunkSize.y))
	$Control/CoordDisplay.text = str(currentChunk)
	%ChunkBorder.position = Vector3(currentChunk.x * chunkSize.x, 0, currentChunk.y * chunkSize.y)
	var root: int = round(sqrt(radius))
	for i in radius:
		var newChunk = currentChunk + (Vector2i(i%root, i/root) - Vector2i(ceil(root/2), ceil(root/2)))
		add_chunk(newChunk)
