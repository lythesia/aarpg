class_name FootstepAudio2D extends AudioStreamPlayer2D

@export var footstep_variants: Array[AudioStream]

var stream_randomizer: AudioStreamRandomizer

func _ready() -> void:
    stream_randomizer = stream

func play_footstep() -> void:
    # dynamically change audio stream according to tilemap layer
    if _get_footstep_type():
        play()

func _get_footstep_type() -> bool:
    for t in get_tree().get_nodes_in_group("tilemaps"):
        if t is TileMapLayer:
            if t.tile_set.get_custom_data_layer_by_name("footstep_type") == -1:
                continue
            var cell: Vector2i = t.local_to_map(t.to_local(global_position))
            var data: TileData = t.get_cell_tile_data(cell)
            if data:
                var type: int = data.get_custom_data("footstep_type")
                var s: AudioStream = footstep_variants[type % footstep_variants.size()]
                stream_randomizer.set_stream(0, s)
                return true
    return false
