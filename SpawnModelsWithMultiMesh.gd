extends Node3D

var total_models = 800
var models_dic: Dictionary = {}

var multimesh: MultiMesh
var last_transform: Transform3D

func _ready():
	set_process(false)
#	get_tree().set_debug_collisions_hint(true)

	create_multimesh()
	spawn_models(50)

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		call_deferred('spawn_models', 10)
		pass

func create_multimesh() -> void:
	multimesh = $MultiMeshInstance3D.multimesh
	multimesh.set_instance_count(total_models)

func spawn_models(new_count) -> void:
	var visible_count = multimesh.visible_instance_count
	var total = visible_count + new_count

	prints(visible_count, new_count, total)

	var pos = 0
	for i in range(visible_count, total):
		var model = $Model.create_instance()

		pos += 1
		model.translate(Vector3(randi() % 25 - 10, 2 + pos, randi() % 25 - 10))
		model.rotate(Vector3(1, 0, 0), randf() * 360)

		model.add_to_group("models")
		models_dic[i] = model
#		multimesh.set_instance_transform(i, models_dic[i].transform)

	multimesh.set_instance_count(total)
	multimesh.set_visible_instance_count(total)

func _process(_delta: float) -> void:
	multi_mesh_set_transform()

func _on_timer_timeout() -> void:
	multi_mesh_set_transform()

func multi_mesh_set_transform():
	for i in models_dic:
		last_transform = multimesh.get_instance_transform(i)
		if last_transform.is_equal_approx(models_dic[i].transform):
			models_dic[i].set_freeze_enabled(true)
			continue
		multimesh.set_instance_transform(i, models_dic[i].transform)

