extends Node2D


@export_category("Levels")
@export var mLevels : Array[PackedScene]

@export var mStartLevel : int = 0

var mCurrentLevelIndex
var mCurrentLevelNode

# Called when the node enters the scene tree for the first time.
func _ready():
	mCurrentLevelIndex = mStartLevel
	spawnLevel(mCurrentLevelIndex)
	pass # Replace with function body.


func spawnLevel(level):
	if mCurrentLevelNode != null:
		mCurrentLevelNode.queue_free()
		await mCurrentLevelNode.tree_exited

	var parentNode = get_parent()
	var collectibleManager = parentNode.get_node("CollectibleManager")

	mCurrentLevelNode = mLevels[level].instantiate()
	parentNode.add_child.call_deferred(mCurrentLevelNode)

	await mCurrentLevelNode.ready

	collectibleManager.spawnCollectibles()
	pass


func nextLevel():
	mCurrentLevelIndex = mCurrentLevelIndex + 1
	if mCurrentLevelIndex < mLevels.size():
		spawnLevel(mCurrentLevelIndex)
