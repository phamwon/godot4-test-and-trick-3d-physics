extends Node3D

var spawn_count: int = 1
var total_models = 50

var model: RigidBody3D
var models_dic: Dictionary = {}

var multimesh: MultiMesh
var last_transform: Transform3D

var is_spawning = false

func _ready():
	$Timer.stop()
	set_process(false)
#	set_physics_process(false)
#	get_tree().set_debug_collisions_hint(true)

	create_multimesh()
	spawn_models(spawn_count)

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		call_deferred('spawn_models', spawn_count)

func create_multimesh() -> void:
	multimesh = $MultiMeshInstance3D.multimesh
	multimesh.set_instance_count(total_models)

func spawn_models(new_count) -> void:
	if is_spawning: return
	is_spawning = true
	
	var visible_count = models_dic.size()
	var total = visible_count + new_count
		
	prints(visible_count, new_count, total)

	for i in range(visible_count, total):
		model = $Model.create_instance()

		model.set_sleeping(true)
		model.translate(Vector3(randi() % 15 - 8, 20, randi() % 15 - 8))
		model.rotate(Vector3(1, 0, 0), randf() * 360)

		model.add_to_group("models")
		models_dic[i] = model
		
#		multimesh.set_instance_transform(i, models_dic[i].transform)
		
	if total >= multimesh.instance_count:
		total_models += 50
		multimesh.set_instance_count(total_models)
		
#		Reindex
		for i in models_dic:
			model = models_dic[i]
			multimesh.set_instance_transform(i, model.transform)
		
	is_spawning = false

func _process(_delta: float) -> void:
	multi_mesh_set_transform()

func _physics_process(_delta: float) -> void:
	multi_mesh_set_transform()

func _on_timer_timeout() -> void:
	multi_mesh_set_transform()

func multi_mesh_set_transform():
	for i in models_dic:
		model = models_dic[i]
		
		if not model.is_inside_tree(): continue
		if model.is_sleeping() and model.is_freeze_enabled(): continue
		
		last_transform = multimesh.get_instance_transform(i)
		if last_transform.is_equal_approx(model.transform):
			continue
				
		multimesh.set_instance_transform(i, model.transform)

func _on_child_exiting_tree(node: Node3D):
	var i = models_dic.find_key(node)
	if not i: return
	
	node.remove_from_group("models")
	multimesh.set_instance_transform(i, Transform3D(Basis(), Vector3(0 , 0, -5)))
