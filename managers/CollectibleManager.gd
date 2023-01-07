extends Node2D


@export var mTileMapObjectLayer : int = 1
@export var mCollectiblePackedScene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	var tileMap = get_node("LevelTemplate/TileMap")
	var usedCells = tileMap.get_used_cells(mTileMapObjectLayer)
	for cellCoord in usedCells:
		var tileData = tileMap.get_cell_tile_data(mTileMapObjectLayer, cellCoord)
		var tileId = tileData.get_custom_data("id")
		if tileId.begins_with("collectible"):
			var node = mCollectiblePackedScene.instantiate()
			node.setType(tileId)
			node.set_position(tileMap.map_to_local(cellCoord))
			add_child.call_deferred(node)
			tileMap.erase_cell(mTileMapObjectLayer, cellCoord)
	pass # Replace with function body.
