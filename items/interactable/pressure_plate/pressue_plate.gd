class_name PressurePlate extends Node2D

signal Activated
signal Deactivated

@export var audio_active: AudioStream
@export var audio_deactive: AudioStream
@export var persistent_key: String

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D

var bodies_entered: int = 0
var is_active: bool = false
var offset_rect: Rect2 # tracks rect offset in atlas
const SPRITE_RECT_SIZE: int = 32

func _ready() -> void:
    offset_rect = sprite.region_rect
    area.body_entered.connect(_on_body_entered)
    area.body_exited.connect(_on_body_exited)

    if persistent_key and WorldState.get_kv(persistent_key):
        is_active = true
        _set_active_silent(true)

func _on_body_entered(body: Node2D) -> void:
    bodies_entered += 1
    _check_activated(body)

func _on_body_exited(body: Node2D) -> void:
    # wait frame for pressure plate to disable collision on exit_tree
    await get_tree().process_frame
    bodies_entered -= 1
    _check_activated(body)

func _check_activated(body: Node2D) -> void:
    if bodies_entered > 0 and !is_active:
        _set_active_silent(true)
        Audio.play_spatial_sound(audio_active, global_position)
        Activated.emit()

        _save_state(body)
    elif bodies_entered <= 0 and is_active:
        _set_active_silent(false)
        Audio.play_spatial_sound(audio_deactive, global_position)
        Deactivated.emit()

        _clear_state()

func _save_state(pushable: Node2D):
    if persistent_key and pushable is Pushable and pushable.persistent_key:
        # store key (instead of bool) to maintain the connection
        WorldState.add_kv(persistent_key, pushable.persistent_key)
        WorldState.add_kv(pushable.persistent_key, pushable.global_position)

func _clear_state():
    if !persistent_key or !WorldState.has_kv(persistent_key):
        return

    var pushable_key: String = WorldState.get_kv(persistent_key)
    if !pushable_key:
        return

    WorldState.remove_kv(persistent_key)
    WorldState.remove_kv(pushable_key)

func _set_active_silent(active: bool):
    if active:
        is_active = true
        # active offset
        sprite.region_rect.position.x = offset_rect.position.x - SPRITE_RECT_SIZE
    else:
        is_active = false
        # restore inactive
        sprite.region_rect.position.x = offset_rect.position.x

func _exit_tree() -> void:
    area.monitoring = false
    area.body_entered.disconnect(_on_body_entered)
    area.body_exited.disconnect(_on_body_exited)
