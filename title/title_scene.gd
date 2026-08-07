extends Node2D

const START_LEVEL: String = "uid://cce13rldqs5om"

@onready var new_btn: Button = %NewBtn
@onready var load_btn: Button = %LoadBtn
@onready var exit_btn: Button = %ExitBtn

func _ready() -> void:
    PlayerHud.hide()
    setup()
    new_btn.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        get_viewport().set_input_as_handled()

func setup() -> void:
    new_btn.pressed.connect(_new_game_pressed)
    if SaveHelper.save_exists():
        load_btn.pressed.connect(_load_game_pressed)
    else:
        load_btn.disabled = true
    exit_btn.pressed.connect(_exit_game_pressed)

    Audio.setup_button_audio(self)

func _new_game_pressed() -> void:
    SceneHelper.new_game_scene(START_LEVEL)

func _load_game_pressed() -> void:
    SaveHelper.load()

func _exit_game_pressed() -> void:
    get_tree().quit()
