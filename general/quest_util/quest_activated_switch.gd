## basically this node is used as "check quest state and activate something"
## for "activate something", this node just emit `AcitvatedChanged` signal,
## user should connect it manually by need
@tool
@icon("res://public/icons/quest_switch.png")
class_name QuestActivatedTrigger extends QuestNode

signal ActivateChanged(v: bool)

enum CheckType {
    ## if has the quest
    HAS_QUEST,

    ## if has completed current step
    QUEST_STEP_COMPLETE,

    ## if is on current step
    ON_CURRENT_QUEST_STEP,

    ## if has completed the quest
    QUEST_COMPLETE,
}

## which quest state is interested
@export var check_type: CheckType = CheckType.HAS_QUEST: set = _set_check_type

## by default, checking happens once at `_ready` (e.g. enter scene and node's initialized)
## if set to `true`, checking happens every time when quest updated
@export var react_to_quest_updated: bool = false

# able to use this flag to do state check (not activated event check)
var is_activated: bool = false

func _ready() -> void:
    if Engine.is_editor_hint():
        return

    check_activated()

    if react_to_quest_updated:
        QuestManager.QuestUpdated.connect(_on_quest_updated)

func check_activated() -> void:
    var quest_state: Dictionary = QuestManager.find_current_quest(quest)
    # not graceful cmp to "not found" ...
    if quest_state.title != "not found":
        match check_type:
            CheckType.HAS_QUEST:
                set_activated(true)

            CheckType.QUEST_STEP_COMPLETE:
                if step > 0 and quest_state.completed_steps >= step:
                    set_activated(true)
                else:
                    set_activated(false)

            CheckType.ON_CURRENT_QUEST_STEP:
                # state.completed_steps + 1 == quest_node.step
                if quest_state.completed_steps + 1 == step:
                    set_activated(true)
                else:
                    set_activated(false)

            CheckType.QUEST_COMPLETE:
                set_activated(quest_state.is_completed)
    # quest not found
    else:
        set_activated(false)

func set_activated(v: bool) -> void:
    is_activated = v
    ActivateChanged.emit(v)

func _on_quest_updated(quest_state: Dictionary) -> void:
    # non-related quest, ignore
    if quest_state.title.to_lower() != quest.title.to_lower():
        return

    check_activated()

func _set_check_type(value: CheckType) -> void:
    check_type = value
    update_summary()

func update_summary() -> void:
    if !quest:
        summary = "Quest is not set"
        return

    var s: String
    match check_type:
        CheckType.HAS_QUEST:
            s = "Check if player has quest"
        CheckType.QUEST_STEP_COMPLETE:
            s = "Check if player has completed step: %s" % _get_step()
        CheckType.ON_CURRENT_QUEST_STEP:
            s = "Check if player is on step: %s" % _get_step()
        CheckType.QUEST_COMPLETE:
            s = "Check if player has completed quest"

    summary = r"UPDATE QUEST:
- Quest: %s
- Check Type: %s
" % [quest.title, s]
