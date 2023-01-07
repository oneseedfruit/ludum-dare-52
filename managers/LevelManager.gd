extends Node


var mLevels : Array[String]

@export var mStartLevel : int = 0

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
	pass


func nextLevel():
	mCurrentLevelIndex = mCurrentLevelIndex + 1
	if mCurrentLevelIndex < mLevels.size():
		spawnLevel(mCurrentLevelIndex)
