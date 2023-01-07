extends Node2D


@export var mTileMapObjectLayer : int = 1
@export var mCollectiblePackedScene : PackedScene

var mCollectibleList: Array[Collectible] = []

func spawnCollectibles():
	var tileMap = get_parent().get_node("LevelTemplate/TileMap")
	if tileMap:
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
				mCollectibleList.append(node)
	pass


func collect(_collectible):
	mCollectibleList.erase(_collectible)
	if mCollectibleList.size() == 0:
		get_parent().get_node("LevelManager").nextLevel()
