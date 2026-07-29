extends Sprite2D

@export var float_speed: float = 2.0
@export var float_range: float = 20.0

var time_passed: float = 0.0
var initial_y: float = 0.0

func _ready() -> void:
	# record initial Y position
	initial_y = position.y

func _process(delta: float) -> void:
	time_passed += delta

	# use sin function to calculate new Y position
	# position.y = initial position + sin(time * speed) * range
	position.y = initial_y + sin(time_passed * float_speed) * float_range
