@tool
class_name Pushable extends RigidBody2D

@export var texture: Texture2D: set = _set_texture
@export var push_speed: float = 30.0
@export var push_audio: AudioStream
## save global position
@export var persistent_key: String

@onready var sprite: Sprite2D = $Sprite2D

var push_dir: Vector2 = Vector2.ZERO

func _ready() -> void:
    _update_texture()

    if Engine.is_editor_hint():
        return

    if persistent_key and WorldState.has_kv(persistent_key):
        var pos: Vector2 = WorldState.get_kv(persistent_key)
        if pos:
            global_position = pos

func _physics_process(_delta: float) -> void:
    if Engine.is_editor_hint():
        return

    linear_velocity = push_dir * push_speed

func _set_texture(value: Texture2D) -> void:
    texture = value
    if Engine.is_editor_hint() and is_node_ready():
        _update_texture()

func _update_texture() -> void:
    if sprite and texture:
        sprite.texture = texture
    elif sprite:
        sprite.texture = null
