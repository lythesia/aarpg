@tool
@icon("res://public/icons/level_transition.svg")
class_name LevelTransInteract extends LevelTrans

func _ready() -> void:
    super()

func _on_load_scene_finished() -> void:
    area.area_entered.connect(_on_player_interact_entered.unbind(1))
    area.area_exited.connect(_on_player_interact_exited.unbind(1))

func _on_player_interact_entered() -> void:
    PlayerManager.PlayerInteracted.connect(_player_interacted)

func _on_player_interact_exited() -> void:
    PlayerManager.PlayerInteracted.disconnect(_player_interacted)

func _player_interacted() -> void:
    _on_player_entered(PlayerManager.get_player())
