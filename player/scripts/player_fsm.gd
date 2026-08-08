class_name PlayerStateMachine extends Node

@onready var idle: PlayerStateIdle = %PlayerStateIdle
@onready var walk: PlayerStateWalk = %PlayerStateWalk
@onready var attack: PlayerStateAttack = %PlayerStateAttack
@onready var stun: PlayerStateStun = %PlayerStateStun
@onready var charge: PlayerStateCharge = %PlayerStateCharge
@onready var spin_attack: PlayerStateSpinAttack = %PlayerStateSpinAttack

const MAX_STATES: int = 3

var states: Array[PlayerState]

var current_state: PlayerState:
    get():
        return states.front()

var previous_state: PlayerState:
    get():
        return states.get(1)

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_DISABLED

func _process(delta: float) -> void:
    var next: PlayerState = current_state.process(delta)
    change_state(next)

func _physics_process(delta: float) -> void:
    var next: PlayerState = current_state.physics_process(delta)
    change_state(next)

func _unhandled_input(event: InputEvent) -> void:
    var next: PlayerState = current_state.handle_input(event)
    change_state(next)

func init(player: Player) -> void:
    states = []
    for c in get_children():
        if c is PlayerState:
            states.append(c)
            # init() may require player, so setup here
            # **ALWAYS** set latest player coz SaveManager is recreating player instance!
            c.player = player

    for c in states:
        c.init()

    if states.size() > 0:
        # first state is always activated!
        current_state.enter()
        # ready to process
        process_mode = Node.PROCESS_MODE_INHERIT

func change_state(new_state: PlayerState) -> void:
    if !new_state:
        # stay
        return

    if new_state == current_state:
        # no change
        return

    if current_state:
        current_state.exit()
    states.push_front(new_state)
    new_state.enter()
    states.resize(MAX_STATES)
