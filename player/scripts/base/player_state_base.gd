@icon("res://public/icons/state.svg")
@abstract
class_name PlayerState extends Node

## player shared among all state instances
static var player: Player

## default next state
var next_state: PlayerState

## initialize state when instantiate before functioning in fsm
func init(): pass

## happens when enter
func enter(): pass

## happens when exit
func exit(): pass

## handle input event and return next state
func handle_input(_event: InputEvent) -> PlayerState: return next_state

## provide `_process` logic and return next state when invoked by `fsm._process`
func process(_delta: float) -> PlayerState: return next_state

## provide `_physics_process` logic and return next state when invoked by `fsm._physics_process`
func physics_process(_delta: float) -> PlayerState: return next_state
