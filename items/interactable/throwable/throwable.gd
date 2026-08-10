class_name Throwable extends Area2D

@export var gravity_strength: float = 980
@export var throw_speed: float = 400
@export var throw_height_strength: float = 100
@export var throw_starting_height: float = 49

# @onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_area: AttackArea = $AttackArea

var picked_up: bool = false
var throwable_object: Node2D
var throw_dir: Vector2

var object_sprite: Sprite2D
var verticle_velocity: float = 0
var ground_height: float = 0
var animation_player: AnimationPlayer # of the object

func _ready() -> void:
    area_entered.connect(_on_area_entered)
    area_exited.connect(_on_area_exited)
    throwable_object = get_parent() # item must be parent
    setup_attack_area()

    # sprite must be child of throwable_object and named "Sprite2D"
    object_sprite = throwable_object.find_child("Sprite2D")
    # coz throwing curve of throwable_object is artificial, we throw the "sprite" instead of collisions
    # so need to keep the ground height of the sprite
    ground_height = object_sprite.position.y
    # animation player must be named "AnimationPlayer"
    animation_player = throwable_object.find_child("AnimationPlayer")

    set_physics_process(false)

func _physics_process(delta: float) -> void:
    object_sprite.position.y += verticle_velocity * delta
    # check if hit "ground"
    if object_sprite.position.y >= ground_height:
        destroy()

    verticle_velocity += gravity_strength * delta
    throwable_object.position += throw_dir * throw_speed * delta


## config throwable_object colli box, and damage area will use this duplicate too
func setup_attack_area() -> void:
    for c in find_children("*", "CollisionShape2D"):
        if !c: continue
        attack_area.add_child(c.duplicate())
        return
    assert(false, "No CollisionShape2D found")


func _on_area_entered(area: Area2D) -> void:
    if area is PlayerInteraction:
        PlayerManager.PlayerInteracted.connect(_on_player_interacted)
    pass

func _on_area_exited(area: Area2D) -> void:
    if area is PlayerInteraction:
        PlayerManager.PlayerInteracted.disconnect(_on_player_interacted)
    pass

func _on_player_interacted() -> void:
    if PlayerManager.interact_handled:
        return

    if !picked_up:
        # grab the flag to prevent other interactables from handling the interaction
        PlayerManager.interact_handled = true
        _disable_collision(throwable_object)

        # make state transition
        PlayerManager.get_player().lift_item(self)

        # clean up
        area_entered.disconnect(_on_area_entered)
        area_exited.disconnect(_on_area_exited)
        picked_up = true

## actually we only want to disable static_body
func _disable_collision(node: Node) -> void:
    for c in node.find_children("*", "CollisionShape2D"):
        if c == self: continue
        (c as CollisionShape2D).disabled = true

func _enable_collision(node: Node) -> void:
    for c in node.find_children("*", "CollisionShape2D"):
        if c == self: continue
        (c as CollisionShape2D).disabled = false

func throw() -> void:
    throwable_object.reparent.call_deferred(get_tree().current_scene, false) # don't keep global position
    throwable_object.position = PlayerManager.get_player().position
    object_sprite.position.y = - throw_starting_height
    verticle_velocity = - throw_height_strength
    set_physics_process(true)

    attack_area.set_active.call_deferred(true)
    attack_area.DamageDealt.connect(destroy)

func drop() -> void:
    throwable_object.reparent.call_deferred(get_tree().current_scene, false)
    throwable_object.position = PlayerManager.get_player().position
    object_sprite.position.y = -40
    verticle_velocity = -100
    throw_speed = 0 # just falling in-place
    set_physics_process(true)

func destroy() -> void:
    set_physics_process(false)
    if animation_player.has_animation("destroy"):
        animation_player.play("destroy")
        await animation_player.animation_finished
    throwable_object.queue_free()
