extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if Input.is_action_pressed("space"):
		start_game()
		pass


func start_game() -> void:
	var sceneTree = get_tree()
	sceneTree.change_scene_to_file("res://game.tscn")
	pass

 
func _on_draw():
	var window_size: Vector2i = DisplayServer.window_get_size()
	var camera: Camera2D = get_node("Camera2D")
	if window_size.x > window_size.y:
		camera.zoom = Vector2(3, 3)
	elif window_size.y > window_size.x:
		camera.zoom = Vector2(4, 4)
