extends Node2D


var mGameOver : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	LevelManager.initializeLevel()


func _input(event):
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
