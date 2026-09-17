class_name SnapScrollContainer
extends ScrollContainer

const WHEEL_SNAP_DELAY := 0.15

@export var item_height: int = 36

@onready var _items: VBoxContainer = $ShopItemsContainer

var _item_separation: int = 6
var _is_dragging := false
var _tween: Tween


func _ready() -> void:
    follow_focus = true
    _item_separation = _items.get_theme_constant("separation")

    var step := _cell_height()
    scroll_vertical_custom_step = step
    get_v_scroll_bar().step = step
    get_v_scroll_bar().gui_input.connect(_on_scroll_bar_input)
    get_viewport().gui_focus_changed.connect(_on_focus_changed)


func reset_scroll() -> void:
    scroll_vertical = 0


func _cell_height() -> int:
    return item_height + _item_separation


func _max_scroll() -> int:
    return maxi(0, int(_items.size.y) - int(size.y))


func _first_visible_row() -> int:
    return int(scroll_vertical / float(_cell_height()))


func _visible_row_count() -> int:
    return maxi(1, int(size.y / float(_cell_height())))


func _scroll_for_index(index: int) -> int:
    var cell := _cell_height()
    var first_row := _first_visible_row()
    var visible_rows := _visible_row_count()

    if index < first_row:
        return index * cell
    if index >= first_row + visible_rows:
        return (index - visible_rows + 1) * cell
    return scroll_vertical


func _set_scroll(target: int, animate := false) -> void:
    target = clampi(target, 0, _max_scroll())
    if target == scroll_vertical:
        return

    if not animate:
        scroll_vertical = target
        return

    if _tween and _tween.is_valid():
        _tween.kill()
    _tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    _tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
    _tween.tween_property(self, "scroll_vertical", target, 0.15)


# --- focus: keyboard / gamepad ---

func _on_focus_changed(node: Node) -> void:
    if _is_dragging or not node is Control or node.get_parent() != _items:
        return
    call_deferred("_snap_to_focused", node)


func _snap_to_focused(item: Control) -> void:
    if is_instance_valid(item):
        _set_scroll(_scroll_for_index(item.get_index()))


# --- pointer: wheel / scrollbar ---

func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton \
            and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
        get_tree().create_timer(WHEEL_SNAP_DELAY).timeout.connect(_snap_to_grid, CONNECT_ONE_SHOT)


func _on_scroll_bar_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        _is_dragging = event.pressed
        if not event.pressed:
            _snap_to_grid()


func _snap_to_grid() -> void:
    if _is_dragging or _items.get_child_count() == 0:
        return
    var cell := _cell_height()
    var row := roundi(float(scroll_vertical) / float(cell))
    _set_scroll(row * cell, true)
