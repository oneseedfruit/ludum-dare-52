class_name Collectible
extends Area2D

var mTileTypeToFrame = {
	"collectible": 0,
	"trap_pothole": 3,
	"trap_outside": 4,
}

var mIsTrap : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", _on_body_entered)
	pass # Replace with function body.

func _on_body_entered(body):
	if visible:
		if body.get_script() == Player:
			if !mIsTrap:
				# TODO: add points
				body.stop_at(position)
				get_parent().collect(self)
				for sound in $CollectedSounds.get_children():
					var stream = sound as AudioStreamPlayer2D
					hide()
					stream.connect("finished", func(): queue_free())
					randomize()
					if randf_range(0, 1) >= 0.5:
						sound.play()
						break
			else:
				body.stop_at(position)
				body.die($AnimatedSprite2D.frame)


func setType(tileId):
	if tileId.begins_with("collectible"):
		$AnimatedSprite2D.set_frame(mTileTypeToFrame["collectible"])
		mIsTrap = false
	elif tileId.begins_with("trap"):
		$AnimatedSprite2D.set_frame(mTileTypeToFrame[tileId])
		mIsTrap = true
	pass
