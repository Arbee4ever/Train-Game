extends Node3D

var noise = FastNoiseLite.new()
var chunkSize = Vector2(200, 200)
var preview = MeshInstance3D.new()

func _init():
	noise.seed = randi()
	noise.frequency = 0.0025
	noise.noise_type = FastNoiseLite.TYPE_VALUE_CUBIC
	
	var trainStation = load("res://assets/trainStation.tscn")
	preview = trainStation.instantiate()
	add_child(preview)

@export var chunkNum = 4
func _ready():
	for i in range(chunkNum):
		print("Generating chunk ", i+1)
		var coords = Vector2(i%int(ceil(sqrt(chunkNum))), i/int(ceil(sqrt(chunkNum))))
		coords.x *= chunkSize.x
		coords.y *= chunkSize.x
		noise.offset = Vector3(coords.x, coords.y, 0)
		
		var chunk = generate_chunk()
		chunk.position = Vector3(coords.x, 0, coords.y)
		
		var shaderMat = StandardMaterial3D.new()
		var imageTexture = ImageTexture.create_from_image(noise.get_image(chunkSize.x, chunkSize.y, false, false, false))
		shaderMat.albedo_texture = imageTexture
		shaderMat.texture_repeat = false
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
		
func _process(delta):
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	var params = PhysicsRayQueryParameters3D.new()
	params.from = $Character/Camera3D.project_ray_origin(mouse_position)
	params.to = params.from + $Character/Camera3D.project_ray_normal(mouse_position) * 1000
	var result = space_state.intersect_ray(params)
	
	if result:
		preview.transform.origin = result.position
	
func _physics_process(delta):
	var input_direction = Input.get_vector("left", "right", "forward", "back")
	var heightInput = Input.get_axis("down", "up")
	$Character.velocity = Vector3(input_direction.x, heightInput, input_direction.y) * 400
	$Character.move_and_slide()
	
var start = Vector3.ZERO
var end = Vector3.ZERO
func _input(event):
	if event.is_action_pressed("left_click"):
		var space_state = get_world_3d().direct_space_state
		var mouse_position = get_viewport().get_mouse_position()
		var params = PhysicsRayQueryParameters3D.new()
		params.from = $Character/Camera3D.project_ray_origin(mouse_position)
		params.to = params.from + $Character/Camera3D.project_ray_normal(mouse_position) * 1000
		var result = space_state.intersect_ray(params)
		if result:
			if start == Vector3.ZERO:
				start = result.position
			elif end == Vector3.ZERO:
				end = result.position
				var curve := Curve3D.new()
				curve.add_point(start, Vector3.ZERO, Vector3(100, 0, 100))
				curve.add_point(end, Vector3(0, 360, 0))
				var path := Path3D.new()
				path.set_curve(curve)
				
				var train = load("res://assets/train.tscn")
				var trainInstance = train.instantiate()
				var pathFollow = PathFollow3D.new()
				pathFollow.loop = false
				pathFollow.add_child(trainInstance)
				path.add_child(pathFollow)
				add_child(path)
				start = Vector3.ZERO
				end = Vector3.ZERO
				
			var trainStation = load("res://assets/trainStation.tscn")
			var trainStationInstance = trainStation.instantiate()
			trainStationInstance.transform.origin = result.position
			add_child(trainStationInstance)
