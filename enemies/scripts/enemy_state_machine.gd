class_name EnemyStateMachine extends Node

var enemy: Enemy
var blackboard: Blackboard
var states: Array[EnemyState]
var current_state: EnemyState:
    get():
        return states.front()
var previous_state: EnemyState:
    get():
        return states.get(1)

func setup(e: Enemy, b: Blackboard) -> void:
    enemy = e
    blackboard = b

    for c in get_children():
        if c is EnemyState:
            c.fsm = self
            c.enemy = e
            c.blackboard = b
            states.append(c)
    # first state is the default one
    current_state.enter()
    # **correctly** set current_state for decision engine
    enemy.decision_engine.current_state = current_state
    enemy.decision_engine.previous_state = null

func change_state(new_state: EnemyState) -> void:
    if !new_state:
        return

    if new_state == current_state:
        current_state.re_enter()
        return

    if current_state:
        current_state.exit()

    states.push_front(new_state)
    new_state.enter()

    if enemy:
        enemy.decision_engine.current_state = new_state
        enemy.decision_engine.previous_state = previous_state

    states.resize(2)

func physics_update(delta: float) -> void:
    if current_state:
        current_state.physics_update(delta)
