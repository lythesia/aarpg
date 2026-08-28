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

var collision_shape: CollisionShape2D

var sprite: Sprite2D
var animation_player: AnimationPlayer
var hazard_area: HazardArea
var damage_area: DamageArea

var fsm: EnemyStateMachine
var decision_engine: DecisionEngine
var blackboard: Blackboard

func _ready() -> void:
    z_index = 1

    if Engine.is_editor_hint():
        set_physics_process(false)
        return

    setup()

func setup() -> void:
    blackboard = Blackboard.new()
    blackboard.hp = hp

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
        elif c is EnemyStateMachine and !fsm:
            fsm = c as EnemyStateMachine
        elif c is DecisionEngine and !decision_engine:
            decision_engine = c as DecisionEngine

    if fsm and decision_engine:
        fsm.setup(self, blackboard)
        decision_engine.enemy = self
        decision_engine.blackboard = blackboard
    else:
        set_physics_process(false)

## move enemy and invoke `fsm.physical_process`
func _physics_process(delta: float) -> void:
    blackboard.update_distance_to_target(global_position)
    fsm.change_state(decision_engine.decide())
    fsm.physics_update(delta)
    move_and_slide()

func get_cardinal_dir(new_dir: Vector2) -> Vector2:
    const CLOCKWISE: Array[Vector2] = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
    var idx = round(((new_dir + 0.1 * blackboard.cardinal_dir).angle() / TAU) * 4)
    return CLOCKWISE[idx]

func update_direction(new_dir: Vector2) -> bool:
    blackboard.dir = new_dir
    if new_dir == Vector2.ZERO:
        return false

    var new_cardinal = get_cardinal_dir(new_dir)
    if new_cardinal == blackboard.cardinal_dir:
        return false
    blackboard.cardinal_dir = new_cardinal

    if blackboard.cardinal_dir == Vector2.LEFT:
        sprite.scale.x = -1.0
    else:
        sprite.scale.x = 1.0

    DirectionChanged.emit(new_cardinal)

    return true


func _dir_to_string(dir: Vector2) -> String:
    match dir:
        Vector2.UP:
            return "up"
        Vector2.DOWN:
            return "down"
        _:
            return "side"

func get_animation(anim_state: String) -> String:
    return "%s_%s" % [anim_state, _dir_to_string(blackboard.cardinal_dir)]

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
        printerr("Animation %s not found" % anim)

func _on_damage_taken(attack_area: AttackArea) -> void:
    blackboard.damage_source = attack_area
    blackboard.hp -= attack_area.damage_amount
    EffectManager.damage_text(attack_area.damage_amount, global_position + Vector2(0, -36))

    if blackboard.hp <= 0.0:
        hazard_area.queue_free()
        damage_area.queue_free()
        collision_shape.set_deferred("disabled", true)
        # on killed, both `WasHit` and `WasKilled` are emitted
        # and `WasKilled` is fired before `WasHit`
        WasKilled.emit()

    WasHit.emit(attack_area)

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
    if !find_children("*", "EnemyStateMachine", false):
        warnings.append("Requires an EnemyStateMachine")
    if !find_children("*", "DecisionEngine", false):
        warnings.append("Requires a DecisionEngine")

    return warnings
