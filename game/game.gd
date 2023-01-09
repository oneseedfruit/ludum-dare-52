extends Node2D


var mGameOver : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	LevelManager.initializeLevel()
	$AudioStreamPlayer.connect("finished", func(): $AudioStreamPlayer.play())


func _input(event):
	if $UI/LevelCompletedPanel.visible:
		level_complete_input(event)
		return

	if event.is_action_pressed("space"):
		if not mGameOver:
			$UI/HelpPanel.visible = !$UI/HelpPanel.visible
		else:
			$UI/WinPanel.visible = false
			mGameOver = false
			LevelManager.initializeLevel()


func game_over() -> void:
	mGameOver = true
	$UI/WinPanel.visible = true


func _on_draw():
	var window_size: Vector2i = DisplayServer.window_get_size()
	if window_size.x > window_size.y:
		var camera: Camera2D = get_node("Camera2D")
		camera.current = true
	elif window_size.y > window_size.x:
		var player_camera: Camera2D = get_node("Player/Camera2D")
		player_camera.current = true
		player_camera.zoom = Vector2(4, 4)


func _on_help_panel_gui_input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		$UI/HelpPanel.hide()


func _on_instruction_gui_input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		$UI/HelpPanel.show()


func update_ui():
	$UI/TopLeft/LevelLabel.text = "Level: {}/{}".format([LevelManager.mCurrentLevelIndex + 1, LevelManager.mLevelPackScenes.size()], "{}")
	$UI/TopLeft/StepLabel.text = "Step: %d" % $Player.mStepUsed


func complete_level():
	var step = $Player.mStepUsed
	$Player.reset_pose_only()
	$Player.set_active(false)
	$UI/LevelCompletedPanel/Label.text = "Step: %d" % step
	$UI/LevelCompletedPanel/IdealStepLabel.text = "Ideal Step: %d" % LevelManager.get_level_ideal_step_count()
	$UI/LevelCompletedPanel.show()


func level_complete_input(event):
	if event.is_action_pressed("left"):
		restart_level()
	elif event.is_action_pressed("right"):
		next_level()

	var threshold = 2
	if event is InputEventScreenDrag:
		if abs(event.relative.y) < 1:
			if event.relative.x > abs(threshold):
				next_level()
			if event.relative.x < -abs(threshold):
				restart_level()


func next_level():
	set_process_input(false)
	LevelManager.nextLevel()
	$UI/LevelCompletedPanel.hide()

	var timer = get_tree().create_timer(0.2)
	await timer.timeout

	$Player.reset()
	$Player.set_active(true)
	set_process_input(true)
	pass


func restart_level():
	set_process_input(false)
	LevelManager.restartLevel()
	$UI/LevelCompletedPanel.hide()

	var timer = get_tree().create_timer(0.2)
	await timer.timeout

	$Player.reset()
	$Player.set_active(true)
	set_process_input(true)
	pass
