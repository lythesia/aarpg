extends CanvasLayer

@onready var hearts_container: HFlowContainer = %HeartsContainer
@onready var game_over_screen: Control = %GameOver
@onready var cont_btn: Button = %ContBtn
@onready var title_btn: Button = %TitleBtn
@onready var animation_player = $Control/GameOver/AnimationPlayer

var hearts: Array[HeartGui] = []

func _ready() -> void:
    for c in hearts_container.get_children():
        if c is HeartGui:
            hearts.append(c)
            c.visible = false

    Audio.setup_button_audio(self)

    cont_btn.pressed.connect(_on_continue_pressed)
    title_btn.pressed.connect(_on_title_pressed)

    hide_game_over()

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

func show_game_over() -> void:
    game_over_screen.show()
    game_over_screen.mouse_filter = Control.MOUSE_FILTER_STOP

    # animation
    animation_player.play("show_game_over")
    await animation_player.animation_finished
    if SaveHelper.save_exists():
        cont_btn.grab_focus()
    else:
        cont_btn.disabled = true
        title_btn.grab_focus()


func hide_game_over() -> void:
    game_over_screen.hide()
    game_over_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
    game_over_screen.modulate = Color(1, 1, 1, 0)

func _on_continue_pressed() -> void:
    hide_game_over()
    SaveHelper.load()

func _on_title_pressed() -> void:
    const TITLE_SCENE: String = "uid://d1w4g1fy3v3oa"

    hide_game_over()
    SceneManager.change_scene(
        ProjectSettings.get_setting("application/run/main_scene", TITLE_SCENE),
        {
            # free player when back to title scene
            "on_fade_out": PlayerManager.get_player().queue_free,
        }
    )
