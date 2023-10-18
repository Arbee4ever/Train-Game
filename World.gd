extends Node3D

var noise = FastNoiseLite.new()
var chunkSize = Vector2(200, 200)

func _init():
	noise.seed = 1
	noise.frequency = 0.005

func _ready():
	var chunkNum = 4;
	for i in range(chunkNum):
		var coords = Vector2(i%(int(ceil(chunkNum/2.0))), i/(int(ceil(chunkNum/2.0))))
		coords.x *= chunkSize.x
		coords.y *= chunkSize.x
		noise.offset = Vector3(coords.x, coords.y, 0)
		
		var chunk = generate_chunk()
		chunk.position = Vector3(coords.x, 0, coords.y)
		
		var shaderMat = StandardMaterial3D.new()
		var imageTexture = ImageTexture.create_from_image(noise.get_image(chunkSize.x, chunkSize.y))
		shaderMat.albedo_texture = imageTexture
		chunk.material_override = shaderMat
	
		add_child(chunk)
	
func generate_chunk():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(chunkSize.x, chunkSize.y)
	plane_mesh.subdivide_depth = chunkSize.x
	plane_mesh.subdivide_width = chunkSize.y
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	
	var array_plane = surface_tool.commit()
	
	var data_tool = MeshDataTool.new()
	
	data_tool.create_from_surface(array_plane, 0)
	
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		vertex.y = noise.get_noise_2d(vertex.x + 100, vertex.z + 100) * 60
		
		data_tool.set_vertex(i, vertex)
	
	array_plane.clear_surfaces()
	
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = surface_tool.commit()
	
	mesh_instance.create_trimesh_collision()
	return mesh_instance

func _process(delta):
	pass
	
func _physics_process(delta):
	get_input()
	$CharacterBody3D.move_and_slide()
	
func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	$CharacterBody3D.velocity = Vector3(input_direction.x, 0, input_direction.y) * 400
	
func _input(event):
	if event.is_action_pressed("left_click"):
		var space_state = get_world_3d().direct_space_state
		var mouse_position = get_viewport().get_mouse_position()
		var params = PhysicsRayQueryParameters3D.new()
		params.from = $CharacterBody3D/Camera3D.project_ray_origin(mouse_position)
		params.to = params.from + $CharacterBody3D/Camera3D.project_ray_normal(mouse_position) * 1000
		var result = space_state.intersect_ray(params)
		if result:
			var scene = load("res://trainStation.tscn")
			var instance = scene.instantiate()
			instance.transform.origin = result.position
			add_child(instance)
