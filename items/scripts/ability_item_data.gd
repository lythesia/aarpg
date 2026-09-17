@tool
class_name AbilityItemData extends PickableItemBase

func ability_type() -> PlayerAbilities.Ability:
    return get_integer("ability_enum") as PlayerAbilities.Ability
