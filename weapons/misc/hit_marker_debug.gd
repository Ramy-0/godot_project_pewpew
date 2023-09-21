extends MeshInstance3D

func init(pos, colour):
	global_position = pos
	material_override.albedo_color = colour
#	print(mesh.material.albedo_color)


func _on_timer_timeout():
	queue_free()
