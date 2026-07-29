extends CanvasLayer

@onready var save_btn: Button = %SaveBtn
@onready var load_btn: Button = %LoadBtn

var is_paused: bool = false

func _ready() -> void:
    save_btn.pressed.connect(_on_save_pressed)
    load_btn.pressed.connect(_on_load_pressed)

    Audio.setup_button_audio(self)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        if !is_paused:
            show_pause_menu()
        else:
            hide_pause_menu()
        get_viewport().set_input_as_handled()

func show_pause_menu() -> void:
    get_tree().paused = true
    visible = true
    is_paused = true
    save_btn.grab_focus()

func hide_pause_menu() -> void:
    get_tree().paused = false
    visible = false
    is_paused = false

func _on_save_pressed() -> void:
    SaveHelper.save()
    print("Saved to slot %0d" % [SaveHelper.current_slot + 1])

func _on_load_pressed() -> void:
    hide_pause_menu()
    SaveHelper.load()
    print("Loaded from slot %0d" % [SaveHelper.current_slot + 1])
