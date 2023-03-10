class_name Player
extends RigidBody2D

# Movement variables (temporarily limit to 250 because too huge will not stop at target)
@export_range(0, 250) var mMoveSpeed: float = 100
@onready var mRay: RayCast2D = $RayCast2D

var mTileSize: int = 16
var mInputs: Dictionary = {
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT,
	"up": Vector2.UP,
	"down": Vector2.DOWN,
}

var mDirection: Vector2 = Vector2.ZERO
var mMoving: bool = false
var mTarget
var mIsDie: bool = false
var death_type: int = 4
var mStepUsed : int = 0


# Make player stop at target position
func stop_at(target) -> void:
	mTarget = target


func die(death_type = 4) -> void:
	mIsDie = true
	self.death_type = death_type


func _die() -> void:
	reset()
	if death_type == 3:
		$AudioFall.play()
		var tween = get_tree().create_tween()
		tween.tween_property($AnimatedSprite2D, "scale", Vector2.ZERO, 1)
		tween.parallel().tween_property($AnimatedSprite2D, "rotation", 360, 1)
	elif death_type == 4:
		$AudioGetBackHere.play()
		get_tree().create_timer(0.2).connect("timeout", func(): $AudioDied.play())
	else:
		$AudioDied.play()


func reset() -> void:
	update_step(true)
	reset_pose_only()


func reset_pose_only() -> void:
	mDirection = Vector2.DOWN
	$AnimationTree.set("parameters/idle/blend_position", mDirection)
	$AnimationTree.get("parameters/playback").travel("idle")


func update_step(reset = false) -> void:
	if !reset:
		mStepUsed = mStepUsed + 1
	else:
		mStepUsed = 0
	get_tree().root.get_node("Game").update_ui()


func _move_toward(dir) -> void:
	mDirection = mInputs[dir]
	_update_raycast()

	if mRay.is_colliding():
		return

	update_step()
	mMoving = true
	mDirection = mInputs[dir]
	$AnimationTree.set("parameters/idle/blend_position", mDirection)
	$AnimationTree.set("parameters/walk/blend_position", mDirection)
	$AnimationTree.get("parameters/playback").travel("walk")


func stop_moving() -> void:
	mMoving = false
	_snap_to_tile()
	$AnimationTree.get("parameters/playback").travel("idle")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_snap_to_tile()
	_update_raycast()


func _unhandled_input(event):
	var threshold = 2
	if not mMoving and not mIsDie:
		if event is InputEventScreenDrag:
			if abs(event.relative.y) < 1:
				if event.relative.x > abs(threshold):
					_move_toward("right")
				if event.relative.x < -abs(threshold):
					_move_toward("left")
			elif abs(event.relative.x) < 1:
				if event.relative.y > abs(threshold):
					_move_toward("down")
				if event.relative.y < -abs(threshold):
					_move_toward("up")


func _physics_process(delta: float) -> void:
	if not mMoving and not mIsDie:
		for dir in mInputs:
			if Input.is_action_pressed(dir):
				_move_toward(dir)

	if mTarget != null and position.distance_squared_to(mTarget) < pow(delta * mMoveSpeed, 2):
		position = mTarget
		mTarget = null
		stop_moving()
		if !mIsDie:
			_bouncing_effect()
		else:
			_die()


	if mMoving:
		var collision: KinematicCollision2D = move_and_collide(mDirection * delta * mMoveSpeed)
		if collision:
			_on_collision(collision)


func _on_collision(collision: KinematicCollision2D) -> void:
	stop_moving()

	var collided_tile_map: TileMap = collision.get_collider() as TileMap

	var collided_at: Vector2 = position + mRay.target_position
	var tile_coords := collided_tile_map.local_to_map(collided_at)

	var layers_with_walls := [0, 1]
	for layer in layers_with_walls:
		var source_id := collided_tile_map.get_cell_source_id(layer, tile_coords, false)
		if source_id == -1:
			continue
		var source: TileSetAtlasSource = collided_tile_map.tile_set.get_source(source_id)
		if source:
			var atlas_coords := collided_tile_map.get_cell_atlas_coords(layer, tile_coords, false)
			var tile_data := source.get_tile_data(atlas_coords, 0)

			var is_wall = tile_data.get_custom_data("is_wall")
			if is_wall:
				$AudioWall.play()
				_bouncing_effect()


# Reset position to tile
func _snap_to_tile() -> void:
	position -= Vector2.ONE * mTileSize * 0.5
	position = position.snapped(Vector2.ONE * mTileSize)
	position += Vector2.ONE * mTileSize * 0.5


# Reset raycast
func _update_raycast() -> void:
	var targetPos = mDirection * mTileSize
	mRay.target_position = targetPos
	mRay.force_raycast_update()


func _bouncing_effect() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($AnimatedSprite2D, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property($AnimatedSprite2D, "scale", Vector2.ONE, 0.1).from_current().set_trans(Tween.TRANS_BOUNCE)


func _on_audio_died_finished():
	var tween = get_tree().create_tween()
	tween.connect("finished", func():
		$AudioTada.play()
		mIsDie = false
	)
	tween.tween_property($AnimatedSprite2D, "scale", Vector2.ONE, 0.5)
	tween.parallel().tween_property($AnimatedSprite2D, "rotation", 0, 0.5)

	LevelManager.restartLevel()


func set_active(active: bool):
	set_process_unhandled_input(active)
	set_physics_process(active)
