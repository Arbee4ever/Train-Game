extends Node3D

func _ready():
	var noise = FastNoiseLite.new()
	noise.seed = 1
	noise.frequency = 0.001
	
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(200, 200)
	plane_mesh.subdivide_depth = 200
	plane_mesh.subdivide_width = 200
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	
	var array_plane = surface_tool.commit()
	
	var data_tool = MeshDataTool.new()
	
	data_tool.create_from_surface(array_plane, 0)
	
	var image = ImageTexture.new()
	
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		vertex.y = noise.get_noise_2d(vertex.x, vertex.z) * 60
		
		data_tool.set_vertex(i, vertex)
	
	array_plane.clear_surfaces()
	
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = surface_tool.commit()
	
	var shaderMat = StandardMaterial3D.new()
	var imageTexture = ImageTexture.create_from_image(noise.get_image(200, 200))
	shaderMat.albedo_texture = imageTexture
	$Sprite2D.texture = imageTexture
	
	mesh_instance.material_override = shaderMat
	
	mesh_instance.create_trimesh_collision()
	
	add_child(mesh_instance)

func _process(delta):
	pass
	
func _input(event):
	if event.is_action_pressed("left_click"):
		var space_state = get_world_3d().direct_space_state
		var mouse_position = get_viewport().get_mouse_position()
		var params = PhysicsRayQueryParameters3D.new()
		params.from = $Camera3D.project_ray_origin(mouse_position)
		params.to = params.from + $Camera3D.project_ray_normal(mouse_position) * 1000
		var result = space_state.intersect_ray(params)
		if result:
			print("Colliding!")
			print(result)
			var scene = load("res://trainStation.tscn")
			var instance = scene.instantiate()
			instance.transform.origin = result.position
			add_child(instance)
