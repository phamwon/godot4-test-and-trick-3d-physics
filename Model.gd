extends RigidBody3D

func _on_mouse_entered() -> void:
	if Input.is_anything_pressed():
		random_tranform()

func random_tranform():
	translate(Vector3(randi() % 10 - 5, 20, randi() % 10 - 5))
	rotate(Vector3(1, 0, 0), randf() * 360)
	set_freeze_enabled(false)
