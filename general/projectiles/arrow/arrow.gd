class_name Arrow extends Projectile

@onready var shadow: Sprite2D = $Shadow
@onready var hazard_area: HazardArea = $HazardArea

# override
func _rotate_sprites(radians: float) -> void:
    sprite.rotate(radians)
    shadow.rotate(radians)
    hazard_area.rotate(radians)
