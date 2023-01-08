extends Node


var mLevels : Array[String]

@export var mStartLevel : int = 0

var mCurrentLevelIndex
var mCurrentLevelNode

func _init() -> void:
    var dir = DirAccess.open("res://levels")
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.begins_with("level_") and file_name.ends_with(".tscn"):
                mLevels.append(file_name)
            file_name = dir.get_next()
    pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    mCurrentLevelIndex = mStartLevel
    spawnLevel(mCurrentLevelIndex)
    pass # Replace with function body.


func spawnLevel(level) -> void:
    if mCurrentLevelNode != null:
        mCurrentLevelNode.queue_free()
        await mCurrentLevelNode.tree_exited

    var parentNode = get_tree().root.get_node("Game")
    var scene = load("levels/%s" % mLevels[level])

    mCurrentLevelNode = scene.instantiate()
    parentNode.add_child.call_deferred(mCurrentLevelNode)

    await mCurrentLevelNode.ready

    _spawnPoint()

    # wait for process_frame so player re-position to spawn point first
    # (else it will collide with collectible that placed on player's lastPos)
    await get_tree().process_frame

    CollectibleManager.spawnCollectibles()

    pass


func nextLevel() -> void:
    mCurrentLevelIndex = mCurrentLevelIndex + 1
    if mCurrentLevelIndex < mLevels.size():
        spawnLevel(mCurrentLevelIndex)


func _spawnPoint() -> void:
    var tileMap = get_node("/root/Game/LevelTemplate/TileMap")
    if tileMap:
        var layerCount = tileMap.get_layers_count()
        for layerIndex in layerCount:
            var usedCells = tileMap.get_used_cells(layerIndex)
            for cellCoord in usedCells:
                var tileData = tileMap.get_cell_tile_data(layerIndex, cellCoord)
                var tileId = tileData.get_custom_data("id")
                if tileId == "player":
                    var playerNode = get_node("/root/Game/Player")
                    var targetPos = tileMap.map_to_local(cellCoord)
                    playerNode.stop_moving()
                    playerNode.set_position(targetPos)
                    tileMap.erase_cell(layerIndex, cellCoord)
    pass


func restartLevel() -> void:
    spawnLevel(mCurrentLevelIndex)
    pass

