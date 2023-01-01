extends ColorRect

var fps = 0
var models
var total: int
var freeze: int
var sleeping: int

var last_update: float = 0

func _process(delta):
	last_update += delta
	if last_update < float(1): return
	last_update = float(0.0)

	$FPS.text = "FPS: " + str(Engine.get_frames_per_second())

	models = get_tree().get_nodes_in_group('models')
	calc_models_data()

	$Models.text = "Models: " + str(total)
	$Freeze.text = "Freeze: " + str(freeze)
	$Sleeping.text = "Sleeping: " + str(sleeping)

func calc_models_data() -> void:
	total = 0
	freeze = 0
	sleeping = 0

	for model in models:
		if model.is_sleeping():
			sleeping += 1
		if model.is_freeze_enabled():
			freeze += 1

		total += 1
