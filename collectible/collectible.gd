extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", _onCollisionEntered)
	pass # Replace with function body.

func _onCollisionEntered(body):
	# TODO: add points
	queue_free()
