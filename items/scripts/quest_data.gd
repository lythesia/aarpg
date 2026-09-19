@tool
class_name QuestData extends PandoraEntity

func quest() -> BaseQuest:
    return get_resource("quest") as BaseQuest
