@tool
@icon("res://public/icons/enemy.svg")
class_name Enemy extends CharacterBody2D

@warning_ignore_start("unused_signal")
signal DirectionChanged(new_dir: Vector2)

signal WasHit(attack_area: AttackArea)

signal WasKilled
@warning_ignore_restore("unused_signal")

@export var hp: int = 3
@export var xp: int = 5
@export var knockback_speed: float = 80
@export var knockback_decelerate: float = 10
@export var invulnerable_dur: float = 0.8
@export var hit_audio: AudioStream

var collision_shape: CollisionShape2D
var sprite: Sprite2D
var animation_player: AnimationPlayer
var hazard_area: HazardArea
var damage_area: DamageArea
var btplayer: BTPlayer

var cardinal_dir: Vector2 = Vector2.DOWN

func _ready() -> void:
    z_index = 1

    if Engine.is_editor_hint():
        set_physics_process(false)
        return

    setup()

func setup() -> void:
    # grab `CharacterBody2D`'s collision shape
    collision_shape = $CollisionShape2D

    for c in get_children():
        # do not override existing one
        if c is Sprite2D and !sprite:
            sprite = c as Sprite2D
        elif c is AnimationPlayer and !animation_player:
            animation_player = c as AnimationPlayer
        elif c is HazardArea and !hazard_area:
            hazard_area = c as HazardArea
        elif c is DamageArea and !damage_area:
            damage_area = c as DamageArea
            (c as DamageArea).DamageTaken.connect(_on_damage_taken)
        elif c is BTPlayer and !btplayer:
            btplayer = c as BTPlayer

    if !btplayer:
        push_error("No BTPlayer specified")
        set_physics_process(false)

func _physics_process(_delta: float) -> void:
    move_and_slide()

func update_direction(new_dir: Vector2) -> bool:
    if new_dir == Vector2.ZERO:
        return false

    var new_cardinal = Utils.calc_cardinal_dir_biased(new_dir, cardinal_dir)
    if new_cardinal == cardinal_dir:
        return false
    cardinal_dir = new_cardinal

    if cardinal_dir == Vector2.LEFT:
        sprite.scale.x = -1.0
    else:
        sprite.scale.x = 1.0

    DirectionChanged.emit(new_cardinal)
    return true


func get_animation(anim_state: String) -> String:
    return "%s_%s" % [anim_state, Utils.cardinal_dir_to_anim_suffix(cardinal_dir)]

func update_animation(anim_state: String) -> void:
    if !animation_player:
        return

    var anim: String = get_animation(anim_state)
    # cardinal directed version
    if animation_player.has_animation(anim):
        animation_player.play(anim)
    # fallback
    elif animation_player.has_animation(anim_state):
        animation_player.play(anim_state)
    else:
        push_error("Animation %s not found" % anim)

func move(vel: Vector2) -> void:
    velocity = vel

func _on_damage_taken(attack_area: AttackArea) -> void:
    btplayer.blackboard.set_var(&"damage_source", attack_area)
    WasHit.emit(attack_area)
    if attack_area.damage_amount > 0:
        hp -= attack_area.damage_amount
        EffectManager.damage_text(attack_area.damage_amount, global_position + Vector2(0, -36))

    if hp <= 0.0:
        hazard_area.queue_free()
        damage_area.queue_free()
        collision_shape.set_deferred("disabled", true)
        WasKilled.emit()

func _get_configuration_warnings() -> PackedStringArray:
    var warnings: PackedStringArray = []

    if !find_children("*", "Sprite2D", false):
        warnings.append("Requires a Sprite2D!")
    if !find_children("*", "AnimationPlayer", false):
        warnings.append("Requires an AnimationPlayer")
    if !find_children("*", "HazardArea", false):
        warnings.append("Requires a HazardArea")
    if !find_children("*", "DamageArea", false):
        warnings.append("Requires a DamageArea")
    if !find_children("*", "BTPlayer", false):
        warnings.append("Requires a BTPlayer")

    return warnings
