extends Node

@export var persistent_data: Dictionary = {}

func has_kv(key: String) -> bool:
    return persistent_data.has(key)

func add_kv(key: String, value: Variant) -> void:
    persistent_data[key] = value

func get_kv(key: String) -> Variant:
    return persistent_data.get(key)

func remove_kv(key: String) -> void:
    persistent_data.erase(key)
