class_name ShopMenu extends CanvasLayer

const ERROR_AUDIO: AudioStream = preload("uid://ctukerl73w5g3")
const OPEN_AUDIO: AudioStream = preload("uid://b53kuwhc3sj4l")
const PURCHASE_AUDIO: AudioStream = preload("uid://brkjm72v82pv1")

const SHOP_ITEM_UI: PackedScene = preload("uid://cvcjfmemha0n3")

@onready var close_btn: Button = %CloseBtn
@onready var coin_label: Label = %CoinLabel
@onready var coin_animation: AnimationPlayer = %CoinAnimation

@onready var item_list: VBoxContainer = %ShopItemsContainer

@onready var item_texture: TextureRect = %ItemTexture
@onready var item_name: Label = %ItemName
@onready var item_price: RichTextLabel = %ItemPrice
@onready var item_hold: RichTextLabel = %ItemHold
@onready var item_desc: Label = %ItemDesc

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS

    close_btn.pressed.connect(exit_menu)
    Audio.setup_button_audio(self)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        get_viewport().set_input_as_handled()
        exit_menu()

func open_menu(shop_inventory: Array[ItemData]) -> void:
    get_tree().paused = true
    Audio.play_ui_audio(OPEN_AUDIO)

    _update_coin_label()

    populate_item_list(shop_inventory)
    if item_list.get_child_count() > 0:
        item_list.get_child(0).grab_focus()
        Audio.setup_button_audio(item_list, false)

func populate_item_list(shop_inventory: Array[ItemData]) -> void:
    # clear existing items
    for c in item_list.get_children():
        item_list.remove_child(c)
        c.queue_free()

    # create new items
    for item in shop_inventory:
        var item_ui: ShopItemUI = SHOP_ITEM_UI.instantiate()
        item_list.add_child(item_ui)
        item_ui.name = "%sBtn" % item.name.replace(" ", "")
        item_ui.setup_item(item)
        # connect signals
        item_ui.focus_entered.connect(focused_item_changed.bind(item))
        item_ui.pressed.connect(purchase_item.bind(item))

func _update_coin_label() -> void:
    var coins: int = PlayerManager.INVENTORY_DATA.get_coin_amount()
    coin_label.text = str(coins)

func focused_item_changed(item: ItemData) -> void:
    if item:
        _update_item_details(item)

func purchase_item(item: ItemData) -> void:
    var can_purchase: bool = PlayerManager.INVENTORY_DATA.get_coin_amount() >= item.buy_price
    if can_purchase:
        Audio.play_ui_audio(PURCHASE_AUDIO)
        PlayerManager.INVENTORY_DATA.add_item(item)
        PlayerManager.INVENTORY_DATA.consume_coin(item.buy_price)
        # ui changes
        _update_coin_label()
        _update_item_details(item)
    else:
        Audio.play_ui_audio(ERROR_AUDIO)
        coin_animation.play("shake_coins")
        coin_animation.seek(0)

func _update_item_details(item: ItemData) -> void:
    item_texture.texture = item.icon
    item_name.text = item.name
    item_price.text = "[color=gray]Price[/color] %d" % item.buy_price
    item_hold.text = "[color=gray]Hold[/color] %d" % _get_item_hold_quantity(item)
    item_desc.text = item.description

func _get_item_hold_quantity(item: ItemData) -> int:
    return PlayerManager.INVENTORY_DATA.get_item_hold_quantity(item)

func exit_menu() -> void:
    get_tree().paused = false
    queue_free()
