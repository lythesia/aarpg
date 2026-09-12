extends BTSequence

const PATH_FINDER: PackedScene = preload("uid://bmkg4awvdj7pe")

## length of raycast to detect obstacles (float)
@export var path_finder_detect_length: float = 5

var path_finder: PathFinder

func _enter() -> void:
    path_finder = PATH_FINDER.instantiate() as PathFinder
    path_finder.name = "PathFinder"
    agent.add_child(path_finder)
    path_finder.set_raycast_len(path_finder_detect_length)
    blackboard.set_var(&"path_finder", path_finder)

func _exit() -> void:
    if path_finder:
        blackboard.erase_var(&"path_finder")
        path_finder.queue_free()
