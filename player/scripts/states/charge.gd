class_name PlayerStateCharge
extends PlayerState

# Included in PlayerState
# static var player: Player

@export var charge_dur_required: float = 0.8
@export var move_speed: float = 80.0
@export var charge_audio: AudioStream

@onready var particles: GPUParticles2D = %ChargeParticles

var timer: float = 0.0
var is_walking: bool = false
var particles_material: ParticleProcessMaterial

func init():
    particles.emitting = false
    particles_material = particles.process_material

func enter():
    timer = charge_dur_required
    is_walking = false
    particles.emitting = true
    particles.amount = 6
    particles.explosiveness = 0
    particles_material.initial_velocity_min = 0
    particles_material.initial_velocity_max = 0
    particles_material.scale_min = 1.2
    particles_material.scale_max = 2
    particles_material.emission_shape_scale = Vector3(1.5, 1.5, 1.5)
    particles_material.radial_accel_min = -150
    particles_material.radial_accel_min = -100

func exit():
    particles.emitting = false

func handle_input(event: InputEvent) -> PlayerState:
    if event.is_action_released("Attack"):
        if timer > 0:
            return player.fsm.idle
        else:
            return player.fsm.spin_attack

    return STAY

func process(delta: float) -> PlayerState:
    if timer > 0:
        timer -= delta
        if timer <= 0:
            # charge complete
            timer = 0
            Audio.play_spatial_sound(charge_audio, player.global_position)

            _increase_particles()
            get_tree().create_timer(0.5).timeout.connect(_decrease_particles)

    # not moving => idle charge
    if player.dir == Vector2.ZERO:
        is_walking = false
        player.update_animation("charge")
    # 1. cardinal direction changed
    # 2. not changed
    # (this allows change cardinal direction while charging)
    elif player.update_direction() or !is_walking:
        is_walking = true
        player.update_animation("charge_walk")

    player.velocity = player.dir * move_speed
    return STAY

func _increase_particles():
    particles.amount = 10
    particles.explosiveness = 1
    particles_material.scale_min = 2
    particles_material.scale_max = 3
    particles_material.initial_velocity_min = 30
    particles_material.initial_velocity_max = 60

func _decrease_particles():
    particles.amount = 4
    particles.explosiveness = 0
    particles_material.scale_min = 1.2
    particles_material.scale_max = 2
    particles_material.initial_velocity_min = 10
    particles_material.initial_velocity_max = 30
