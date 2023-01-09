extends Node2D


@export var mGameScene : PackedScene

@onready var me_want_banana = $BigMonke/MeWantBanana
@onready var where_my_banana = $BigMonke/WhereMyBanana
@onready var go_get_banana = $BigMonke/GoGetBananaNow
@onready var monke_screaming = $Monke/MonkeScreaming

var _started = false


# Called when the node enters the scene tree for the first time.
func _ready():
	_started = false
	pass # Replace with function body.


func _input(event):
	if not _started and event.is_action_pressed("space") or event is InputEventScreenTouch:
		_started = true
		me_want_banana.connect("finished", func(): 
			where_my_banana.play()
			$BigMonke/AnimatedSprite2D.play()
			get_tree().create_timer(0.5).connect("timeout", func():
				$BigMonke.scale.x = -$BigMonke.scale.x
			)
			get_tree().create_timer(1.0).connect("timeout", func():
				$BigMonke.scale.x = -$BigMonke.scale.x
			)
			get_tree().create_timer(2.0).connect("timeout", func():
				$BigMonke/AnimatedSprite2D.stop()
				$BigMonke/AnimatedSprite2D.frame = 1
			)
			get_tree().create_timer(3.0).connect("timeout", func():
				go_get_banana.play()
				$BigMonke/AnimatedSprite2D.play()
			)
		)
		me_want_banana.play()
		
		get_tree().create_timer(6.5).connect("timeout", func(): 
			$Monke/AnimationTree.active = true
			$Monke/MonkeScreaming.play()
		)
		$Monke/MonkeScreaming.connect("finished", func():
			$Monke.scale.x = -$Monke.scale.x
			var tween = get_tree().create_tween()
			tween.connect("finished", func(): start_game())
			tween.tween_property($Monke, "position", Vector2(-200, $Monke.position.y), 1)
		)
		

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
