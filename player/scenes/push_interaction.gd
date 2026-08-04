@tool
class_name PushInteraction extends PlayerInteraction

var pushable: Pushable = null

func _ready() -> void:
    super()

    if Engine.is_editor_hint():
        return

    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
    if pushable:
        # player is pressing direction key
        if player.dir != Vector2.ZERO:
            # if starting push or during pushing towards same direction
            if pushable.push_dir == Vector2.ZERO or pushable.push_dir == player.cardinal_dir:
                pushable.push_dir = player.cardinal_dir
            # during pushing but player changes direction
            else:
                pushable.push_dir = Vector2.ZERO
        else:
            pushable.push_dir = Vector2.ZERO

func _on_body_entered(body: Node2D) -> void:
    if body is Pushable and !pushable:
        pushable = body

func _on_body_exited(body: Node2D) -> void:
    if body is Pushable and pushable == body:
        pushable.push_dir = Vector2.ZERO # clear push direction also when exit
        pushable = null
