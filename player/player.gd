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

var mMoving = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	_snap_to_tile()


func _physics_process(delta):
	var collision = move_and_collide(mMoving * delta * mMoveSpeed)
	if collision:
		mMoving = Vector2.ZERO
		_snap_to_tile()
	
	if mMoving == Vector2.ZERO:
		for dir in mInputs:
			if Input.is_action_pressed(dir):
				mMoving = mInputs[dir]
				var targetPos = mMoving * mTileSize
				mRay.target_position = targetPos
				mRay.force_raycast_update()
				
				
# reset position to tile
func _snap_to_tile():
	position -= Vector2.ONE * mTileSize * 0.5
	position = position.snapped(Vector2.ONE * mTileSize)
	position += Vector2.ONE * mTileSize * 0.5
