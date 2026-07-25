@icon("res://public/icons/state.svg")
@abstract
class_name PlayerState extends Node

## player shared among all state instances
static var player: Player
const STAY: PlayerState = null

## initialize state when instantiate before functioning in fsm
func init(): pass

## happens when enter
func enter(): pass

## happens when exit
func exit(): pass

## handle input event and return next state
func handle_input(_event: InputEvent) -> PlayerState: return STAY

## provide `_process` logic and return next state when invoked by `fsm._process`
func process(_delta: float) -> PlayerState: return STAY

## provide `_physics_process` logic and return next state when invoked by `fsm._physics_process`
func physics_process(_delta: float) -> PlayerState: return STAY
