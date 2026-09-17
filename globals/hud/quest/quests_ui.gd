class_name QuestsUI extends Control

const QUEST_ITEM: PackedScene = preload("uid://csykq2urwsyl0")
const QUEST_STEP: PackedScene = preload("uid://devo3gsikybh2")

@onready var container: VBoxContainer = %QuestsContainer
@onready var details_container: VBoxContainer = %QuestDetailsContainer
@onready var title_label: Label = $MarginContainer/HBoxContainer/QuestDetailsContainer/TitleLabel
@onready var desc_label: Label = $MarginContainer/HBoxContainer/QuestDetailsContainer/DescLabel

var last_focused_slot: int = 0

func _ready() -> void:
    clear()
    visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
    if is_visible_in_tree():
        update_quests_list()

func update_quests_list() -> void:
    clear()

    # sort
    QuestManager.sort_current_quests()

    # update UI
    var idx: int = 0
    for q in QuestManager.current_quests:
        var quest_data: Quest = QuestManager.find_quest_by_title(q.title)
        if quest_data == null:
            continue
        var quest_item_ui: QuestItemUI = QUEST_ITEM.instantiate()
        if idx > 0:
            quest_item_ui.name += str(idx)
        container.add_child(quest_item_ui) # add child at `idx`
        quest_item_ui.initialize(quest_data, q)

        # connect focus_entered
        quest_item_ui.focus_entered.connect(update_quest_details.bind(idx, quest_data, q))
        idx += 1

    await get_tree().process_frame
    update_slot_focus()

func clear() -> void:
    # clear: remove from tree first so get_child only sees new items
    for v in container.get_children():
        container.remove_child(v)
        v.queue_free()
    clear_quest_details()

func update_slot_focus() -> void:
    if container.get_child_count() == 0:
        return

    last_focused_slot = mini(last_focused_slot, container.get_child_count() - 1)
    var quest_item: QuestItemUI = container.get_child(last_focused_slot)
    # to avoid: https://github.com/godotengine/godot/issues/76696
    quest_item.grab_focus.call_deferred()

# `state` always not null
func update_quest_details(focused_idx: int, quest_data: Quest, state: Dictionary) -> void:
    clear_quest_details()

    title_label.text = quest_data.title
    desc_label.text = quest_data.description

    for i in quest_data.steps.size():
        var quest_step_ui: QuestStepUI = QUEST_STEP.instantiate()
        if i > 0:
            quest_step_ui.name += str(i)
        details_container.add_child(quest_step_ui)
        # todo: not graceful using "not found" ...
        var is_completed: bool = state.title != "not found" and state.completed_steps >= i + 1
        quest_step_ui.initialize(quest_data.steps[i], is_completed)

    last_focused_slot = mini(focused_idx, container.get_child_count() - 1)

func clear_quest_details() -> void:
    title_label.text = ""
    desc_label.text = ""
    for c in details_container.get_children():
        if c is QuestStepUI:
            details_container.remove_child(c)
            c.queue_free()
