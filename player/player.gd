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

var mMoving: Vector2 = Vector2.ZERO
var mTarget


# Make player stop at target position
func stop_at(target) -> void:
    mTarget = target


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    _snap_to_tile()
    _update_raycast()


func _physics_process(delta: float) -> void:
    if mMoving == Vector2.ZERO:
        for dir in mInputs:
            if Input.is_action_pressed(dir):
                mMoving = mInputs[dir]
                _update_raycast()

    if mTarget != null and position.distance_squared_to(mTarget) < pow(delta * mMoveSpeed, 2):
        position = mTarget
        mTarget = null
        mMoving = Vector2.ZERO
        _snap_to_tile()

    var collision: KinematicCollision2D = move_and_collide(mMoving * delta * mMoveSpeed)
    if collision:
        _on_collision(collision)


func _on_collision(collision: KinematicCollision2D) -> void:
    mMoving = Vector2.ZERO
    _snap_to_tile()

    var collided_tile_map: TileMap = collision.get_collider() as TileMap

    var collided_at: Vector2 = position + mRay.target_position
    var tile_coords := collided_tile_map.local_to_map(collided_at)

    var layers_with_walls := [0, 1]
    for layer in layers_with_walls:
        var source_id := collided_tile_map.get_cell_source_id(layer, tile_coords, false)
        var source: TileSetAtlasSource = collided_tile_map.tile_set.get_source(source_id)
        if source:
            var atlas_coords := collided_tile_map.get_cell_atlas_coords(layer, tile_coords, false)
            var tile_data := source.get_tile_data(atlas_coords, 0)

            var is_wall = tile_data.get_custom_data("is_wall")
            if is_wall:
                var tween = get_tree().create_tween()
                tween.tween_property($AnimatedSprite2D, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_ELASTIC)
                tween.tween_property($AnimatedSprite2D, "scale", Vector2.ONE, 0.1).from_current().set_trans(Tween.TRANS_BOUNCE)


# Reset position to tile
func _snap_to_tile() -> void:
    position -= Vector2.ONE * mTileSize * 0.5
    position = position.snapped(Vector2.ONE * mTileSize)
    position += Vector2.ONE * mTileSize * 0.5


# Reset raycast
func _update_raycast() -> void:
    var targetPos = mMoving * mTileSize
    mRay.target_position = targetPos
    mRay.force_raycast_update()
