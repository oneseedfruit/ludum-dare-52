class_name Player
extends RigidBody2D

# Movement variables (temporarily limit to 250 because too huge will not stop at target)
@export_range(0, 250) var mMoveSpeed : float = 100
@onready var mRay = $RayCast2D

var mTileSize = 16
var mInputs = {
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT,
	"up": Vector2.UP,
	"down": Vector2.DOWN,
}

var mMoving = Vector2.ZERO
var mTarget

# Called when the node enters the scene tree for the first time.
func _ready():
	_snap_to_tile()
	_update_raycast()


func _physics_process(delta):
	var collision = move_and_collide(mMoving * delta * mMoveSpeed)
	if collision:
		mMoving = Vector2.ZERO
		_snap_to_tile()

	if mTarget != null and position.distance_squared_to(mTarget) < pow(delta * mMoveSpeed, 2):
		position = mTarget
		mTarget = null
		mMoving = Vector2.ZERO
		_snap_to_tile()

	if mMoving == Vector2.ZERO:
		for dir in mInputs:
			if Input.is_action_pressed(dir):
				mMoving = mInputs[dir]
				_update_raycast()


# Reset position to tile
func _snap_to_tile():
	position -= Vector2.ONE * mTileSize * 0.5
	position = position.snapped(Vector2.ONE * mTileSize)
	position += Vector2.ONE * mTileSize * 0.5


# Reset raycast
func _update_raycast():
	var targetPos = mMoving * mTileSize
	mRay.target_position = targetPos
	mRay.force_raycast_update()


# Make player stop at target position
func stopAt(target):
	mTarget = target
