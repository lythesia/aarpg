extends BTAction

## animation to play
@export var anim: StringName = &"cast_spell"
## BB variable of face direction: Vector2
@export var face_dir: StringName = &"appear_face"
## BB variable of horizontal beam attacks: Array[BeamAttack]
@export var beams_h: StringName = &"beams_h"
## BB variable of vertical beam attacks: Array[BeamAttack]
@export var beams_v: StringName = &"beams_v"

var enemy: Enemy
var should_fail: bool = false
var beams: Array[BeamAttack]

func _enter() -> void:
    enemy = agent as Enemy
    should_fail = false
    beams = []

    var _face_dir: Vector2 = blackboard.get_var(face_dir) as Vector2
    if !_face_dir:
        push_error("DarkWizardBeamAttack: %s not set" % face_dir)
        should_fail = true
        return

    var _beams_h: Array[BeamAttack] = blackboard.get_var(beams_h, []) as Array[BeamAttack]
    var _beams_v: Array[BeamAttack] = blackboard.get_var(beams_v, []) as Array[BeamAttack]

    match _face_dir:
        Vector2.DOWN:
            beams.append(_beams_h[0])
            beams.append(_beams_h.slice(-1, 0, -1).pick_random())
        Vector2.UP:
            beams.append(_beams_h[-1])
            beams.append(_beams_h.slice(0, -1).pick_random())
        _:
            beams.append_array(_beams_v)

    for b in beams:
        b.activate()

    enemy.animation_player.play(anim)

func _tick(_delta: float) -> Status:
    if should_fail:
        return Status.FAILURE

    if enemy.animation_player.is_playing():
        return Status.RUNNING
    else:
        return Status.SUCCESS
