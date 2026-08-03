@icon("res://public/icons/player_sensor.svg")
class_name PlayerSensor extends Area2D

@warning_ignore("unused_signal")
signal PlayerEntered

@warning_ignore("unused_signal")
signal PlayerExited

@warning_ignore("unused_signal")
signal StartSearching

@export var search_dur: float = 0.5

const PLAYER_LAYER: int = 5

var enemy: Enemy
var search_timer: float = 0.0

func _ready() -> void:
    search_timer = 0.0

    set_collision_layer_value(1, false)
    set_collision_mask_value(1, false)

    if owner is Enemy:
        enemy = owner
        set_collision_mask_value(PLAYER_LAYER, true)
        body_entered.connect(_on_body_entered)
        body_exited.connect(_on_body_exited)
        enemy.DirectionChanged.connect(_on_direction_changed)
    else:
        set_physics_process(false)
        self.enabled = false

func _physics_process(delta: float) -> void:
    # so semantics here: KEEP exited for `searching_dur` long then safely trigger `PlayerExited`
    if search_timer > 0.0:
        search_timer -= delta
        if search_timer <= 0.0:
            PlayerExited.emit()
            enemy.blackboard.target = null

func _on_body_entered(body: Node2D) -> void:
    if body is not Player:
        return

    PlayerEntered.emit()
    enemy.blackboard.target = body as Player
    search_timer = 0 # reset timer when player entered, esp during searching

func _on_body_exited(body: Node2D) -> void:
    if body is not Player:
        return

    StartSearching.emit()
    search_timer = search_dur # start timer

func _on_direction_changed(new_dir: Vector2) -> void:
    match new_dir:
        Vector2.UP: rotation_degrees = 180
        Vector2.DOWN: rotation_degrees = 0
        Vector2.LEFT: rotation_degrees = 90
        Vector2.RIGHT: rotation_degrees = -90
