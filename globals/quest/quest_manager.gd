extends Node

signal QuestUpdated(quest: Dictionary)

const QUEST_DATA_DIR: String = "res://quests"

# all quests
var quests: Array[Quest]
# current active/archived quests, each as `{ title = "not found", is_completed = false, completed_steps = [] }`
@export var current_quests: Array[Dictionary] = []

func _ready() -> void:
    # gather all quests
    gather_quests()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("Test"):
        update_quest("Short Quest", "", true)
        update_quest("Lost Flute", "Find the magical flute", false)
        update_quest("Long Quest", "Step.1", false)

func gather_quests() -> void:
    quests.clear()
    var quest_files: PackedStringArray = DirAccess.get_files_at(QUEST_DATA_DIR)

    for v in quest_files:
        quests.append(load("{0}/{1}".format([QUEST_DATA_DIR, v])) as Quest)
    print("loaded %d quests" % [quests.size()])

func update_quest(title: String, current_completed_step: String, is_completed: bool = false) -> void:
    var quest_idx: int = get_current_quest_id_by_title(title)
    var quest: Dictionary
    if quest_idx == -1:
        quest = {
            title = title,
            is_completed = false,
            completed_steps = [],
        }
        current_quests.append(quest)
    else:
        quest = current_quests[quest_idx]

    quest.is_completed = is_completed
    if !current_completed_step.is_empty() and !(quest.completed_steps as Array[String]).has(current_completed_step):
        quest.completed_steps.append(current_completed_step)

    QuestUpdated.emit(quest)
    # todo: display notification
    if quest.is_completed:
        var quest_res: Quest = find_quest_by_title(quest.title)
        if quest_res:
            reward_quest(quest_res)

func reward_quest(quest: Quest) -> void:
    PlayerManager.gain_xp(quest.reward_xp)
    for v in quest.reward_items:
        PlayerManager.INVENTORY_DATA.add_item(v.item, v.quantity)

# searching
func find_current_quest(q: Quest) -> Dictionary:
    # find quest associated with a given quest object
    for v in current_quests:
        if q.title == v.title:
            return v
    return {
        title = "not found",
        is_completed = false,
        completed_steps = [],
    }

func find_quest_by_title(title: String) -> Quest:
    for v in quests:
        if v.title.to_lower() == title.to_lower():
            return v
    return null

func get_current_quest_id_by_title(title: String) -> int:
    return current_quests.find_custom(func(v: Dictionary) -> bool: return v.title.to_lower() == title.to_lower())

func sort_current_quests() -> void:
    current_quests.sort_custom(
        func(a: Dictionary, b: Dictionary) -> bool:
            if a.is_completed != b.is_completed:
                return !a.is_completed
            else:
                return a.title.to_lower() < b.title.to_lower()
    )
