extends Node


@export var mCollectiblePackedScene : PackedScene

var mCollectibleList: Array[Collectible] = []

func cleanUp() -> void:
    for n in get_children():
        remove_child(n)
        n.queue_free()

func spawnCollectibles():
    cleanUp()
    var tileMap = get_node("/root/Game/LevelTemplate/TileMap")
    if tileMap:
        var layerCount = tileMap.get_layers_count()
        for layerIndex in layerCount:
            var usedCells = tileMap.get_used_cells(layerIndex)
            for cellCoord in usedCells:
                var tileData = tileMap.get_cell_tile_data(layerIndex, cellCoord)
                var tileId = tileData.get_custom_data("id")
                if tileId.begins_with("collectible") or tileId.begins_with("trap"):
                    var node = mCollectiblePackedScene.instantiate()
                    node.setType(tileId)
                    node.set_position(tileMap.map_to_local(cellCoord))
                    add_child.call_deferred(node)
                    tileMap.erase_cell(layerIndex, cellCoord)
                    if !node.mIsTrap:
                        mCollectibleList.append(node)
    pass


func collect(_collectible):
    mCollectibleList.erase(_collectible)
    if mCollectibleList.size() == 0:
        get_node("/root/LevelManager").nextLevel()
