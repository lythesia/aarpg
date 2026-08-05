class_name Boomerang extends CharacterBody2D

enum State {INACTIVE, THROW, RETURN}

@export var acceleration: float = 500
@export var max_speed: float = 400
@export var catch_audio: AudioStream

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var player: Player
var dir: Vector2
var speed: float = 0
var state: State = State.INACTIVE

func _ready() -> void:
    visible = false
    state = State.INACTIVE
    player = PlayerManager.get_player()

func _physics_process(delta: float) -> void:
    match state:
        State.INACTIVE:
            visible = false
        State.THROW:
            speed -= acceleration * delta
            position += dir * speed * delta
            # return at apex
            if speed <= 0:
                state = State.RETURN
            # return if hit wall
            elif move_and_collide(dir * speed * delta):
                state = State.RETURN
        State.RETURN:
            # no collision when returning
            dir = global_position.direction_to(player.global_position)
            speed += acceleration * delta
            position += dir * speed * delta
            if global_position.distance_to(player.global_position) <= 10:
                if catch_audio:
                    Audio.play_spatial_sound(catch_audio, player.global_position)
                queue_free()
                return

    var speed_ratio: float = speed / max_speed
    audio_player.pitch_scale = 0.5 + speed_ratio * 0.5

func throw(throw_dir: Vector2) -> void:
    dir = throw_dir
    speed = max_speed
    state = State.THROW
    animation_player.play("fly")
    if catch_audio:
        Audio.play_spatial_sound(catch_audio, player.global_position)
    visible = true
