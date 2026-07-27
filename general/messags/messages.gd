extends Node

@warning_ignore_start("unused_signal")
signal PlayerInteracted(player: Player)

signal NewSceneReady(target_lt_name: String, player_offset: Vector2)

signal LoadSceneFinished
@warning_ignore_restore("unused_signal")
