extends Area2D


var mTileIdToFrame = {
	"collectible_1": 0,
	"collectible_2": 1,
	"collectible_3": 2,
	"collectible_4": 3,
	"collectible_5": 4,
	"collectible_6": 5,
	"collectible_7": 6,
	"collectible_8": 7,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", _onCollisionEntered)
	pass # Replace with function body.

func _onCollisionEntered(body):
	if body.get_script() == Player:
		# TODO: add points
		body.stopAt(position)
		queue_free()


func setType(tileId):
	$AnimatedSprite2D.set_frame(mTileIdToFrame[tileId])
	pass
