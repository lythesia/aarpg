extends CanvasLayer

@onready var hearts_container: HFlowContainer = %HeartsContainer

var hearts: Array[HeartGui] = []

func _ready() -> void:
    for c in hearts_container.get_children():
        if c is HeartGui:
            hearts.append(c)
            c.visible = false

func update_hp(hp: int, max_hp: int):
    update_max_hp(max_hp)
    for i in roundi(max_hp * 0.5):
        update_heart(i, hp)

func update_heart(idx: int, current_hp: int):
    hearts[idx].heart_frame = clampi(current_hp - idx * 2, 0, 2)

func update_max_hp(max_hp: int):
    var n = roundi(max_hp * 0.5)
    for i in hearts.size():
        hearts[i].visible = i < n
