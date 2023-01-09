extends Node2D


@export var mGameScene : PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event):
	if event.is_action_pressed("space") or event is InputEventScreenTouch:
		start_game()


func start_game() -> void:
	var sceneTree = get_tree()
	sceneTree.change_scene_to_packed(mGameScene)
	pass

 
func _on_draw():
	var window_size: Vector2i = DisplayServer.window_get_size()
	var camera: Camera2D = get_node("Camera2D")
	if window_size.x > window_size.y:
		camera.zoom = Vector2(3, 3)
	elif window_size.y > window_size.x:
		camera.zoom = Vector2(4, 4)
