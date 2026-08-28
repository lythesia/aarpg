class_name StatsUI extends Control

@onready var lv_label: Label = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/LvLabel
@onready var xp_label: Label = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/XpLabel
@onready var atk_label: Label = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/AtkLabel
@onready var def_label: Label = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer4/DefLabel

func _ready() -> void:
    PauseMenu.PauseMenuShown.connect(update_stats)

func update_stats() -> void:
    var player: Player = PlayerManager.get_player()
    if !player:
        printerr("no player instance!")
        return

    lv_label.text = str(player.level)
    if player.level >= PlayerManager.LEVEL_UP_XP.size():
        xp_label.text = "- / -"
    else:
        xp_label.text = "%d / %d" % [player.xp, PlayerManager.LEVEL_UP_XP[player.level]]
    atk_label.text = str(player.atk)
    def_label.text = str(player.def)
