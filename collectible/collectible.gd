class_name Collectible
extends Area2D


var mTileTypeToFrame = {
	"collectible": 0,
	"trap": 4,
}

var mIsTrap : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", _on_body_entered)
	pass # Replace with function body.

func _on_body_entered(body):
	if body.get_script() == Player:
		if !mIsTrap:
			# TODO: add points
			body.stop_at(position)
			get_parent().collect(self)
			queue_free()
		else:
			body.stop_at(position)
			body.die()


func setType(tileId):
	if tileId.begins_with("collectible"):
		$AnimatedSprite2D.set_frame(mTileTypeToFrame["collectible"])
		mIsTrap = false
	elif tileId.begins_with("trap"):
		$AnimatedSprite2D.set_frame(mTileTypeToFrame["trap"])
		mIsTrap = true
	pass
