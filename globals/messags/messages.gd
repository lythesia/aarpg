extends Node

@warning_ignore_start("unused_signal")
signal NewSceneLoaded(target_level_trans: String, player_offset: Vector2)

signal ChangeSceneFinished

signal TileMapLayerEnabled(tilemap_layer: TileMapLayer)
@warning_ignore_restore("unused_signal")
