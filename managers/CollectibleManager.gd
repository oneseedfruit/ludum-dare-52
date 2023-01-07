extends Node2D


@export var mTileMapObjectLayer : int = 1
@export var mCollectiblePackedScene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	var tileMap = get_node("LevelTemplate/TileMap")
	var usedCells = tileMap.get_used_cells(mTileMapObjectLayer)
	for cellCoord in usedCells:
		var cell = tileMap.get_cell_atlas_coords(mTileMapObjectLayer, cellCoord)
		if cell.x == 6 and cell.y == 9:
			var node = mCollectiblePackedScene.instantiate()
			node.set_position(tileMap.map_to_local(cellCoord))
			add_child.call_deferred(node)
			tileMap.erase_cell(mTileMapObjectLayer, cellCoord)

	pass # Replace with function body.
