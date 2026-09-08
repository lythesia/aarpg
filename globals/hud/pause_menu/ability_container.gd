class_name AbilityContainer extends GridContainer

func update_ability_items(vs: Array[PlayerAbilities.Ability]) -> void:
    for c in get_children():
        if c.get_index() as PlayerAbilities.Ability in vs:
            c.visible = true
        else:
            c.visible = false
