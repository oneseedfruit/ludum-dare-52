extends RigidBody2D

# movement variable
@export var mMoveSpeed : float = 100
@onready var mRay = $RayCast2D
var mTileSize = 16
var mInputs = {
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT,
	"up": Vector2.UP,
	"down": Vector2.DOWN,
}
var mMoving = false
var mTilePerSec = 0

# queue movement (so player can pre-enter movement before reaching end)
@export var mQueueInputDuration : float = 0.24
@onready var mQueueInputTimer = $Timer
var mQueueInput

# Called when the node enters the scene tree for the first time.
func _ready():
	# calculate move duration per tile
	mTilePerSec = mTileSize / mMoveSpeed

	# reset position to tile
	position = position.snapped(Vector2.ONE * mTileSize)
	position += Vector2.ONE * mTileSize * 0.5

	# setup debounce timer
	mQueueInputTimer.set_wait_time(mQueueInputDuration)
	mQueueInputTimer.set_one_shot(true)
	mQueueInputTimer.connect("timeout", func (): 
		mQueueInput = null
	)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _unhandled_input(event):
	for dir in mInputs.keys():
		if event.is_action_pressed(dir):
			if (mMoving):
				queueInput(dir)
			else:
				move(dir)
	pass

func move(dir):
	var targetPos = mInputs[dir] * mTileSize
	mRay.target_position = targetPos
	mRay.force_raycast_update()
	if !mRay.is_colliding():
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", targetPos, mTilePerSec).set_trans(Tween.TRANS_LINEAR).as_relative()
		tween.connect("finished", func (): 
			move(dir)
		)
		mMoving = true
	elif mQueueInput != null:
		move(mQueueInput)
		mQueueInput = null
	else:
		mMoving = false
	pass

func queueInput(dir):
	# stop timer and restart it
	if !mQueueInputTimer.is_stopped():
		mQueueInputTimer.stop()
	# record to mQueueInput
	mQueueInput = dir
	mQueueInputTimer.start()
	pass
