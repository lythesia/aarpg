extends CanvasLayer

signal PauseMenuShown
signal PauseMenuHidden

@onready var tab_container: TabContainer = %TabContainer

# inventory tab
@onready var inventory: Control = %Inventory
@onready var inventory_ui: InventoryUI = %InventoryUI
@onready var item_desc_label: Label = %ItemDesc
@onready var coin_label: Label = %CoinLabel

# quests tab
@onready var quests: QuestsUI = %Quests

# system tab
@onready var system: Control = %System
@onready var save_btn: Button = %SaveBtn
@onready var load_btn: Button = %LoadBtn
@onready var title_btn: Button = %TitleBtn

var is_paused: bool = false

func _ready() -> void:
    visible = false
    inventory_ui.clear_inventory()
    item_desc_label.text = ""

    # system tab has no script attached, do it in-place
    system.visibility_changed.connect(func():
        if system.visible:
            save_btn.grab_focus()
    )

    save_btn.pressed.connect(_on_save_pressed)
    load_btn.pressed.connect(_on_load_pressed)
    title_btn.pressed.connect(_on_title_pressed)

    Audio.setup_button_audio(self)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        Audio.ui_cancel()
        if !is_paused:
            show_pause_menu()
        else:
            hide_pause_menu()
        get_viewport().set_input_as_handled()

    if is_paused:
        if event.is_action_pressed("LB"):
            prev_tab()
        elif event.is_action_pressed("RB"):
            next_tab()

func show_pause_menu() -> void:
    get_tree().paused = true
    tab_container.current_tab = 0 # inventory tab as default
    visible = true
    is_paused = true
    PauseMenuShown.emit()

func hide_pause_menu() -> void:
    get_tree().paused = false
    visible = false
    is_paused = false
    PauseMenuHidden.emit()

func prev_tab() -> void:
    tab_container.current_tab = wrapi(tab_container.current_tab - 1, 0, tab_container.get_tab_count())

func next_tab() -> void:
    tab_container.current_tab = wrapi(tab_container.current_tab + 1, 0, tab_container.get_tab_count())

func _on_save_pressed() -> void:
    SaveHelper.save()
    # print("Saved to slot_%02d" % [SaveHelper.current_slot + 1])
    hide_pause_menu()
    PlayerHud.queue_notification("Save Completed", "Saved to slot_%02d" % [SaveHelper.current_slot + 1])

func _on_load_pressed() -> void:
    hide_pause_menu()
    SaveHelper.load()
    # print("Loaded from slot_%02d" % [SaveHelper.current_slot + 1])

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
