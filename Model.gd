extends RigidBody3D

const max_collistions: int = 10
const max_count_to_defreeze: int = 6
const max_time_to_sleep: int = 2
const max_sleep_time_to_freeze: int = 1

func random_tranform():
	translate(Vector3(randi() % 6 - 3, 5, randi() % 6 - 3))
	rotate(Vector3(1, 0, 0), randf() * 360)

func make_freeze():
	set_sleeping(true)
	set_freeze_enabled(true)
	set_meta("collistion_count", 0)
	
func defreeze():
	$SleepTimer.stop()
	$FreezeTimer.stop()
	set_sleeping(false)
	set_freeze_enabled(false)
	set_meta("count_to_defreeze", 0)
	
func is_ready_to_freeze() -> bool:	
	var collistion_count = get_meta("collistion_count")
	return collistion_count >= max_collistions
	
func is_ready_to_defreeze() -> bool:
	var count_to_defreeze = get_meta("count_to_defreeze")
	return count_to_defreeze >= max_count_to_defreeze

func _on_sleeping_state_changed():
	if is_sleeping():
		set_meta("last_sleep_time", Time.get_ticks_msec())
		$FreezeTimer.start(max_sleep_time_to_freeze)
	else:
		$FreezeTimer.stop()

func _on_body_entered(body):
	if not body is StaticBody3D:
		var count_to_defreeze = get_meta("count_to_defreeze")
		set_meta("count_to_defreeze", count_to_defreeze + 1)
		
		if is_ready_to_defreeze():
			defreeze()
			return
	
	var collistion_count = get_meta("collistion_count")
	set_meta("collistion_count", collistion_count + 1)
		
	if is_ready_to_freeze():
		make_freeze()
		return

func _on_body_exited(body):
	if body is StaticBody3D: return
	$SleepTimer.start(max_time_to_sleep)

func _on_freeze_timer_timeout():
	make_freeze()
	$FreezeTimer.stop()

func _on_sleep_timer_timeout():
	if is_sleeping(): return
	$SleepTimer.stop()
	set_sleeping(true)
	emit_signal("sleeping_state_changed")

func _on_visible_on_screen_notifier_3d_screen_exited():
	queue_free()
	get_parent().remove_child(self)

func _on_input_event(_camera, _event, _position, _normal, _shape_idx):
	defreeze()
	random_tranform()
