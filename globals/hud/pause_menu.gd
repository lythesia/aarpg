extends CanvasLayer

signal PauseMenuShown
signal PauseMenuHidden

@onready var sys_btn: Button = %SystemBtn
@onready var save_btn: Button = %SaveBtn
@onready var load_btn: Button = %LoadBtn
@onready var back_btn: Button = %BackBtn
@onready var title_btn: Button = %TitleBtn
@onready var inventory_screen: Control = %InventoryScreen
@onready var system_screen: Control = %SystemScreen
@onready var inventory_ui: InventoryUI = %Inventory
@onready var item_desc_label: Label = %ItemDesc
@onready var coin_label: Label = %CoinLabel

var is_paused: bool = false
var is_system_screen: bool = false

func _ready() -> void:
    visible = false
    inventory_ui.clear_inventory()
    item_desc_label.text = ""

    sys_btn.pressed.connect(_on_system_pressed)
    save_btn.pressed.connect(_on_save_pressed)
    load_btn.pressed.connect(_on_load_pressed)
    back_btn.pressed.connect(_on_back_pressed)
    title_btn.pressed.connect(_on_title_pressed)

    Audio.setup_button_audio(self)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        Audio.ui_cancel()
        if !is_paused:
            is_system_screen = false
            show_pause_menu()
        elif is_system_screen:
            hide_system_screen()
        else:
            hide_pause_menu()
        get_viewport().set_input_as_handled()

func show_pause_menu() -> void:
    get_tree().paused = true
    visible = true
    is_paused = true
    # always show inventory first instead of system screen
    inventory_screen.visible = true
    system_screen.visible = false
    PauseMenuShown.emit()

func hide_pause_menu() -> void:
    get_tree().paused = false
    visible = false
    is_paused = false
    PauseMenuHidden.emit()

func show_system_screen() -> void:
    inventory_screen.visible = false
    system_screen.visible = true
    is_system_screen = true
    save_btn.grab_focus()

func hide_system_screen() -> void:
    inventory_screen.visible = true
    system_screen.visible = false
    is_system_screen = false
    sys_btn.grab_focus()

func _on_system_pressed() -> void:
    show_system_screen()

func _on_save_pressed() -> void:
    SaveHelper.save()
    # print("Saved to slot_%02d" % [SaveHelper.current_slot + 1])

func _on_load_pressed() -> void:
    hide_pause_menu()
    SaveHelper.load()
    # print("Loaded from slot_%02d" % [SaveHelper.current_slot + 1])

func _on_back_pressed() -> void:
    hide_system_screen()

func _on_title_pressed() -> void:
    const TITLE_SCENE: String = "uid://d1w4g1fy3v3oa"
    hide_pause_menu()
    SceneManager.change_scene(
        ProjectSettings.get_setting("application/run/main_scene", TITLE_SCENE),
        {
            # free player when back to title scene
            "on_fade_out": PlayerManager.get_player().queue_free,
        }
    )
