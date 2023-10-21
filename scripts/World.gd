extends Node3D

var noise = FastNoiseLite.new()
var chunkSize = Vector2(200, 200)

func _init():
	noise.seed = randi()
	noise.frequency = 0.0025
	noise.noise_type = FastNoiseLite.TYPE_VALUE_CUBIC

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
		shaderMat.albedo_color = Color.DARK_GREEN
		shaderMat.texture_repeat = false
		chunk.material_override = shaderMat
	
		add_child(chunk)
	
func generate_chunk():
	var mesh_instance = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(chunkSize.x, chunkSize.y)
	mesh_instance.mesh = plane_mesh
	mesh_instance.create_trimesh_collision()
	return mesh_instance
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

func _physics_process(delta):
	var input_direction = Input.get_vector("left", "right", "forward", "back")
	var heightInput = Input.get_axis("down", "up")
	$Character.velocity = Vector3(input_direction.x, heightInput, input_direction.y) * 400
	$Character.move_and_slide()
