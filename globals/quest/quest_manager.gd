extends Node

signal QuestStarted(quest: BaseQuest)

@warning_ignore("unused_signal")
signal QuestStepUpdated(quest_id: int, quest_title: String, step: QuestStep)

signal QuestCompleted(quest: BaseQuest)

signal QuestRewarded(quest_title: String, msg: String)

var quests_cache: Dictionary = {}

func get_active_quests() -> Array[BaseQuest]:
    var quests: Array[Quest] = QuestSystem.get_active_quests()
    return _cont_quests(quests)

func get_completed_quests() -> Array[BaseQuest]:
    var pool: BaseQuestPool = QuestSystem.get_pool("Completed")
    return _cont_quests(pool.get_all_quests())

func is_quest_active(quest_entity_id: String) -> bool:
    var quest: BaseQuest = get_quest_by_entity_id(quest_entity_id)
    return QuestSystem.is_quest_active(quest)

func is_quest_completed(quest_entity_id: String) -> bool:
    var quest: BaseQuest = get_quest_by_entity_id(quest_entity_id)
    return QuestSystem.is_quest_completed(quest)

func start_quest(quest_entity_id: String) -> BaseQuest:
    var quest: BaseQuest = get_quest_by_entity_id(quest_entity_id)

    if !can_start_quest(quest_entity_id, quest):
        push_warning("Quest already started or completed: %s" % [quest_entity_id])
        return quest

    QuestSystem.start_quest(quest)
    QuestStarted.emit(quest)
    return quest

func can_start_quest(quest_entity_id: String, quest: BaseQuest = null) -> bool:
    if !quest:
        quest = get_quest_by_entity_id(quest_entity_id)

    return !QuestSystem.is_quest_active(quest) and !QuestSystem.is_quest_completed(quest)

func complete_quest(quest_entity_id: String) -> BaseQuest:
    var quest: BaseQuest = get_quest_by_entity_id(quest_entity_id)
    if !can_complete_quest(quest_entity_id, quest):
        push_warning("Quest not started or completed already or objectives not met: %s" % [quest_entity_id])
        return quest

    quest.objective_completed = true
    QuestSystem.complete_quest(quest)
    QuestCompleted.emit(quest)

    # do rewards
    reward_quest(quest)

    return quest

func can_complete_quest(quest_entity_id: String, quest: BaseQuest = null) -> bool:
    if !quest:
        quest = get_quest_by_entity_id(quest_entity_id)

    return QuestSystem.is_quest_active(quest) and \
        !QuestSystem.is_quest_completed(quest) and \
        quest.get_completed_steps_count() == quest.get_steps_count()

func reward_quest(quest: BaseQuest) -> void:
    var message: Array[String] = []

    if quest.reward_xp > 0:
        PlayerManager.gain_xp(quest.reward_xp)
        message.append("%d xp" % quest.reward_xp)
    if !quest.rewards.is_empty():
        for v in quest.rewards:
            PlayerManager.INVENTORY_DATA.add_item(v.item, v.quantity)
            message.append("%s x%d" % [v.item.name(), v.quantity])
    if !message.is_empty():
        QuestRewarded.emit(quest.quest_name, "\n".join(message))

# 1. try cache first
# 2. try pools: active, completed, (available not used), these all be init on load
# 3. completely new quest: pandora -> cache, it may be later add to pool
func get_quest_by_entity_id(quest_entity_id: String) -> BaseQuest:
    # 1. cache
    if quest_entity_id in quests_cache:
        return quests_cache[quest_entity_id]

    # get pandora entity first: we need quest id
    var quest_data: QuestData = Pandora.get_entity(quest_entity_id) as QuestData
    assert(quest_data != null, "Quest data not found: %s" % [quest_entity_id])
    var quest: BaseQuest = quest_data.quest()
    var deep_copy: BaseQuest = quest.duplicate(true)

    # 2. pools
    var pooled: BaseQuest = QuestSystem._get_quest_by_id(quest.id)
    if pooled:
        return pooled

    # 3. cache pandora copy
    quests_cache[quest_entity_id] = deep_copy
    return deep_copy

func _cont_quests(base: Array[Quest]) -> Array[BaseQuest]:
    var vs: Array[BaseQuest] = []
    for v in base:
        if v is BaseQuest:
            vs.append(v)
    return vs

func clear() -> void:
    quests_cache.clear()
    QuestSystem.reset_pool()

#region save/load
func save_to_dict(_s: SaveKitSerializer) -> Dictionary:
    var active_quests = QuestSystem.serialize_quests("Active")
    var completed_quests = QuestSystem.serialize_quests("Completed")
    var pool_state = QuestSystem.pool_state_as_dict()
    return {
        "active_quests": active_quests,
        "completed_quests": completed_quests,
        "pool_state": pool_state,
    }

func load_from_dict(_d: SaveKitDeserializer, data: Dictionary) -> void:
    # 1. load pandora first
    var category := Pandora.get_category(PandoraCategories.QUESTS)
    var quests: Array[Quest] = []
    for e in Pandora.get_all_entities(category):
        var quest_data: QuestData = e as QuestData
        var quest := quest_data.quest().duplicate(true) as BaseQuest
        quests_cache[quest_data.get_entity_id()] = quest
        quests.append(quest)

    # 2. then populate quest states
    # 2.1 dispatch quests to pools
    QuestSystem.restore_pool_state_from_dict(data.get("pool_state", {}), quests)
    # 2.2 restore quest states
    QuestSystem.deserialize_quests(data.get("active_quests", {}), "Active")
    QuestSystem.deserialize_quests(data.get("completed_quests", {}), "Completed")

    # 3. step state & signals restore handled by BaseQuest deser

## connect signals for quest steps[br]
## it must be called after savekit's load
func connect_quest_steps() -> void:
    for quest in QuestSystem.get_active_quests():
        if quest is BaseQuest:
            quest.on_load()
#endregion
