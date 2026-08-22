@icon("res://public/icons/state.svg")
class_name EnemyState extends Node

@export var anim_name: String

const STAY: EnemyState = null

var fsm: EnemyStateMachine
var enemy: Enemy
var blackboard: Blackboard

func setup(f: EnemyStateMachine, e: Enemy, b: Blackboard) -> void:
    fsm = f
    enemy = e
    blackboard = b

func enter() -> void: pass

func re_enter() -> void: pass

func exit() -> void: pass

## non-physics related updates
func update(_delta: float) -> void: pass

## physics related updates
func physics_update(_delta: float) -> void: pass
