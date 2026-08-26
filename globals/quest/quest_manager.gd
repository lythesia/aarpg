extends Node

signal QuestUpdated(quest: Dictionary)

const QUEST_DATA_DIR: String = "res://quests"

# all quests
var quests: Array[Quest]
# current active/archived quests, each as `{ title = "not found", is_completed = false, completed_steps = 0 }`
@export var current_quests: Array[Dictionary] = []

func _ready() -> void:
    # gather all quests
    gather_quests()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("Test"):
        # accept_or_advance_quest("Short Quest")
        # accept_or_advance_quest("Lost Flute")
        # accept_or_advance_quest("Long Quest")
        pass

func gather_quests() -> void:
    quests.clear()
    var quest_files: PackedStringArray = DirAccess.get_files_at(QUEST_DATA_DIR)

    for v in quest_files:
        quests.append(load("{0}/{1}".format([QUEST_DATA_DIR, v])) as Quest)
    print("loaded %d quests" % [quests.size()])

func accept_or_advance_quest(title: String) -> void:
    var quest_data: Quest = find_quest_by_title(title)
    assert(quest_data != null, "Quest not found: %s" % [title])
    var quest_idx: int = get_current_quest_id_by_title(title)
    var quest: Dictionary

    if quest_idx == -1:
        quest = {
            title = title,
            is_completed = false,
            completed_steps = 0,
        }
        current_quests.append(quest)
    else:
        quest = current_quests[quest_idx]
        quest.completed_steps += 1

    quest.is_completed = quest.completed_steps == quest_data.steps.size()

    QuestUpdated.emit(quest)

    if quest.is_completed:
        reward_quest(quest_data)

func reward_quest(quest: Quest) -> void:
    PlayerManager.gain_xp(quest.reward_xp)
    for v in quest.reward_items:
        PlayerManager.INVENTORY_DATA.add_item(v.item, v.quantity)

# searching
func quest_accepetd(title: String) -> bool:
    return current_quests.find_custom(
        func(v: Dictionary) -> bool:
            return v.title.to_lower() == title.to_lower()
    ) != -1

func find_current_quest(q: Quest) -> Dictionary:
    return find_current_quest_by_title(q.title)

func find_current_quest_by_title(title: String) -> Dictionary:
    for v in current_quests:
        if title.to_lower() == v.title.to_lower():
            return v

    return {
        title = "not found",
        is_completed = false,
        completed_steps = 0,
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
