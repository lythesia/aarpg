@tool
@abstract
class_name ItemUseEffect extends PandoraEntity

func type() -> String:
    return get_string("effect_type")

func amount() -> int:
    return get_integer("amount")

@abstract
func use() -> void
