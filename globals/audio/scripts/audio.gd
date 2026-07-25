extends Node

func play_spatial_sound(audio: AudioStream, pos: Vector2, pitch_scale: float = 1.0) -> void:
    var player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
    add_child(player)
    player.bus = "SFX"
    player.global_position = pos
    player.stream = audio
    player.pitch_scale = pitch_scale
    player.finished.connect(player.queue_free)
    player.play()
