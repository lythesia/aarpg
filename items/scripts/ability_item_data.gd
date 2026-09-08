class_name AbilityItemData extends ItemData

@export var ability_type: PlayerAbilities.Ability

# override
# non-usable item
func use() -> bool:
    return false
