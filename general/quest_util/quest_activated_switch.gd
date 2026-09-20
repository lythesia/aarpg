## basically this node is used as "check quest state and activate something"
## for "activate something", this node just emit `AcitvatedChanged` signal,
## user should connect it manually by need
@tool
@icon("res://public/icons/quest_switch.png")
class_name QuestActivatedTrigger extends QuestNode

signal ActivateChanged(v: bool)

enum CheckType {
    ## if has the quest
    QUEST_ACTIVED,

    ## if has completed step
    QUEST_STEP_COMPLETED,

    ## if is on current step
    ON_CURRENT_QUEST_STEP,

    ## if has completed the quest
    QUEST_COMPLETE,
}

## which quest state is interested
@export var check_type: CheckType = CheckType.QUEST_ACTIVED: set = _set_check_type

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
        QuestManager.QuestStepUpdated.connect(_on_quest_updated)

func check_activated() -> void:
    match check_type:
        CheckType.QUEST_ACTIVED:
            var is_active: bool = QuestManager.is_quest_active(quest_data.get_entity_id())
            set_activated(is_active)

        CheckType.QUEST_STEP_COMPLETED:
            var quest: BaseQuest = QuestManager.get_quest_by_entity_id(quest_data.get_entity_id())
            set_activated(quest.get_completed_steps_count() > step)

        CheckType.ON_CURRENT_QUEST_STEP:
            var quest: BaseQuest = QuestManager.get_quest_by_entity_id(quest_data.get_entity_id())
            set_activated(step == quest.get_completed_steps_count())

        CheckType.QUEST_COMPLETE:
            set_activated(QuestManager.is_quest_completed(quest_data.get_entity_id()))

func set_activated(v: bool) -> void:
    is_activated = v
    ActivateChanged.emit(v)

func _on_quest_updated(quest_id: int, _title: String, _step: QuestStep) -> void:
    var quest: BaseQuest = QuestManager.get_quest_by_entity_id(quest_data.get_entity_id())
    # non-related quest, ignore
    if quest_id != quest.id:
        return

    check_activated()

func _set_check_type(value: CheckType) -> void:
    check_type = value
    update_summary()

# overrides
func update_summary() -> void:
    if !quest_data:
        summary = "Quest is not set"
        return

    var s: String
    match check_type:
        CheckType.QUEST_ACTIVED:
            s = "Check if player has quest activated"
        CheckType.QUEST_STEP_COMPLETED:
            s = "Check if player has completed step: %s" % _get_step().description
        CheckType.ON_CURRENT_QUEST_STEP:
            s = "Check if player is on step: %s" % _get_step().description
        CheckType.QUEST_COMPLETE:
            s = "Check if player has completed quest"

    summary = r"UPDATE QUEST:
- Quest: %s
- Check Type: %s
" % [quest_data.quest().quest_name, s]
