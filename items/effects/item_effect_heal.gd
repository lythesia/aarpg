class_name ItemEffectHeal extends ItemEffect

@export var heal_amount: int = 1
@export var use_audio: AudioStream

func use() -> void:
    var player = PlayerManager.get_player()
    player.hp += heal_amount
    if use_audio:
        Audio.play_ui_audio(use_audio)
