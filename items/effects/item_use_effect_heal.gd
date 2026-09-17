@tool
class_name ItemUseEffectHeal extends ItemUseEffect

func audio() -> AudioStream:
    return get_resource("audio") as AudioStream

func use() -> void:
    var player: Player = PlayerManager.get_player()
    if !player:
        print("Player not found")
        return

    player.hp += amount() as int
    Audio.play_ui_audio(audio())
