class_name TerrainNoise extends FastNoiseLite

func get_noise(pos: Vector2):
	return get_noise_2d(pos.x, pos.y) * 600 + 50
