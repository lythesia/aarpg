class_name EsDarkWizardAttack
extends EnemyState

# Included in EnemyState
# @export var anim_name: String = "idle"
# var fsm: EnemyStateMachine
# var enemy: Enemy
# var blackboard: Blackboard

var beams_h: Array[BeamAttack] = [] # horizontal beams
var beams_v: Array[BeamAttack] = [] # vertical beams

var ended: bool = false

func setup(f: EnemyStateMachine, e: Enemy, b: Blackboard) -> void:
    super(f, e, b)
    var beam_attacks: Node2D = enemy.get_node("../BeamAttacks")
    assert(beam_attacks, "BeamAttacks not found")
    for c in beam_attacks.get_children():
        if c is BeamAttack:
            # horizontal beam from top to bottom
            if c.name.containsn("_h"):
                beams_h.append(c)
            # vertical beam from left to right
            elif c.name.containsn("_v"):
                beams_v.append(c)

func enter() -> void:
    ended = false
    var prev_state: EnemyState = enemy.fsm.previous_state
    if prev_state is EsTeleport:
        await _beam_attack(prev_state.curr_dir)
        ended = true
    else:
        ended = true

func exit() -> void:
    pass

func physics_update(_delta: float) -> void:
    pass

func _beam_attack(dir: EsTeleport.Dir) -> void:
    var beams: Array[BeamAttack] = []
    match dir:
        EsTeleport.Dir.DOWN:
            beams.append(beams_h[0])
            beams.append(beams_h.slice(-1, 0, -1).pick_random())
        EsTeleport.Dir.UP:
            beams.append(beams_h[-1])
            beams.append(beams_h.slice(0, -1).pick_random())
        _:
            beams.append_array(beams_v)

    for b in beams:
        b.activate()

    enemy.animation_player.play("cast_spell")
    await enemy.animation_player.animation_finished
