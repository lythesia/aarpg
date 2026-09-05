extends CanvasLayer

@onready var hearts_container: HFlowContainer = %HeartsContainer

@onready var abilities: Control = %Abilities
@onready var abilities_container: HBoxContainer = %AbilitiesContainer
@onready var arrow_count_label: Label = %ArrowCountLabel
@onready var bomb_count_label: Label = %BombCountLabel

@onready var game_over_screen: Control = %GameOver
@onready var cont_btn: Button = %ContBtn
@onready var title_btn: Button = %TitleBtn
@onready var animation_player: AnimationPlayer = $Control/GameOver/AnimationPlayer

@onready var boss_hud: Control = %BossHud
@onready var boss_hp_bar: TextureProgressBar = %BossHpBar
@onready var boss_label: Label = %BossLabel
@onready var notification_ui: NotificationUI = %Notification

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
    hide_boss_hud()

    update_ability_ui(0)

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
            # clear player when back to title scene
            "on_fade_out": PlayerManager.clear_player
        }
    )

func show_boss_hud(boss_name: String) -> void:
    boss_label.text = boss_name
    boss_hud.show()

func hide_boss_hud() -> void:
    boss_hud.hide()

func update_boss_hp(hp: int, max_hp: int) -> void:
    boss_hp_bar.value = clampf(float(hp) / float(max_hp) * 100, 0, 100)

func queue_notification(title: String, message: String) -> void:
    notification_ui.push_notification(title, message)

func update_ability_ui(idx: int, audio: bool = false) -> void:
    for c in abilities_container.get_children():
        c.self_modulate = Color.TRANSPARENT
        c.modulate = Color(0.6, 0.6, 0.6, 0.8)

    var ability: CanvasItem = abilities_container.get_child(idx)
    ability.self_modulate = Color.WHITE
    ability.modulate = Color.WHITE

    if audio:
        Audio.ui_focus_change()

func update_arrow_count_label(count: int) -> void:
    arrow_count_label.text = str(count)

func update_bomb_count_label(count: int) -> void:
    bomb_count_label.text = str(count)
