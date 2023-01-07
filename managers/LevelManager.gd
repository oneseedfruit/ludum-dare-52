extends Node


var mLevels : Array[String]

@export var mStartLevel : int = 0
@export var mTileMapObjectLayer : int = 1

var mCurrentLevelIndex
var mCurrentLevelNode

func _init():
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
func _ready():
	mCurrentLevelIndex = mStartLevel
	spawnLevel(mCurrentLevelIndex)
	pass # Replace with function body.


func spawnLevel(level):
	if mCurrentLevelNode != null:
		mCurrentLevelNode.queue_free()
		await mCurrentLevelNode.tree_exited

	var parentNode = get_node("/root/Game")
	var collectibleManager = get_node("/root/CollectibleManager")
	var scene = load("levels/%s" % mLevels[level])

	mCurrentLevelNode = scene.instantiate()
	parentNode.add_child.call_deferred(mCurrentLevelNode)

	await mCurrentLevelNode.ready

	collectibleManager.spawnCollectibles()
	
	_spawnPoint()

	pass


func nextLevel():
	mCurrentLevelIndex = mCurrentLevelIndex + 1
	if mCurrentLevelIndex < mLevels.size():
		spawnLevel(mCurrentLevelIndex)


func _spawnPoint():
	var tileMap = get_node("/root/Game/LevelTemplate/TileMap")
	if tileMap:
		var usedCells = tileMap.get_used_cells(mTileMapObjectLayer)
		for cellCoord in usedCells:
			var tileData = tileMap.get_cell_tile_data(mTileMapObjectLayer, cellCoord)
			var tileId = tileData.get_custom_data("id")
			if tileId == "player":
				var playerNode = get_node("/root/Game/Player")
				var targetPos = tileMap.map_to_local(cellCoord)
				playerNode.mMoving = Vector2.ZERO
				playerNode.set_position(targetPos)
				tileMap.erase_cell(mTileMapObjectLayer, cellCoord)
	pass
