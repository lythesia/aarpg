@tool
class_name PandoraHuman extends PandoraEntity

func is_same(other: PandoraHuman) -> bool:
    return get_entity_id() == other.get_entity_id()
