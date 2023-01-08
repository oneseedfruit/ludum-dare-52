extends Node2D


var mGameOver : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	LevelManager.initializeLevel()
	pass # Replace with function body.


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
