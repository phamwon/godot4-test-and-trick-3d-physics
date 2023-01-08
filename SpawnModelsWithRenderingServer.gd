extends Node3D

var mesh
var multimesh_rid
var multimesh_instance
var multimesh_visible_count: int
var last_transform: Transform3D
var models_dic: Dictionary = {}

var total_models = 800

func _ready():
	set_process(false)
#	RenderingServer.set_render_loop_enabled(false)
#	get_tree().set_debug_collisions_hint(true)

	create_multimesh()
	spawn_models(50)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			call_deferred('spawn_models', 10)

func create_multimesh() -> void:
	$MultiMeshInstance3D.queue_free()

	var scenario = get_world_3d().get_scenario()
	multimesh_instance = RenderingServer.instance_create()
	RenderingServer.instance_set_scenario(multimesh_instance, scenario)

	multimesh_rid = RenderingServer.multimesh_create()
	RenderingServer.instance_set_base(multimesh_instance, multimesh_rid)

	mesh = load('res://assets/RockMesh.tres')

	RenderingServer.multimesh_set_mesh(multimesh_rid, mesh.get_rid())
	RenderingServer.multimesh_allocate_data(multimesh_rid, total_models, RenderingServer.MULTIMESH_TRANSFORM_3D)
	RenderingServer.multimesh_set_visible_instances(multimesh_rid, 0)

	# !? Fixed buffer_update error when multimesh_allocate_data called
	var multimesh_buffer = RenderingServer.multimesh_get_buffer(multimesh_rid)
	RenderingServer.multimesh_set_buffer(multimesh_rid, multimesh_buffer)

func spawn_models(new_count) -> void:
	var visible_count = RenderingServer.multimesh_get_visible_instances(multimesh_rid)
	var total = visible_count + new_count

	prints(visible_count, new_count, total)
	RenderingServer.multimesh_allocate_data(multimesh_rid, total, RenderingServer.MULTIMESH_TRANSFORM_3D)
	RenderingServer.multimesh_set_visible_instances(multimesh_rid, total)

	var pos = 0
	for i in range(visible_count, total):
		var model = $Model.create_instance()

		pos += 1
		model.translate(Vector3(randi() % 25 - 10, 10 + pos, randi() % 25 - 10))
		model.rotate(Vector3(1, 0, 0), randf() * 360)

		model.add_to_group("models")
		models_dic[i] = model
#		RenderingServer.multimesh_instance_set_transform(multimesh_rid, i, models_dic[i].transform)

func _process(_delta: float) -> void:
	multi_mesh_set_transform()

func _on_timer_timeout() -> void:
	multi_mesh_set_transform()

func multi_mesh_set_transform():
	for i in models_dic:
		last_transform = RenderingServer.multimesh_instance_get_transform(multimesh_rid, i)
		if last_transform.is_equal_approx(models_dic[i].transform):
			models_dic[i].set_freeze_enabled(true)
			continue
		RenderingServer.multimesh_instance_set_transform(multimesh_rid, i, models_dic[i].transform)

