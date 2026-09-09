class_name PlayerSavedata extends SaveKitResource

@export_file("*.tscn") var scene: String = SceneHelper.DEFAULT_SCENE
@export var pos: Vector2 = Vector2.ZERO
@export var hp: int = Player.DEFAULT_HP
@export var max_hp: int = Player.DEFAULT_HP
@export var level: int = 1
@export var xp: int = 0
@export var base_atk: int = 1
@export var base_def: int = 1
@export var abilities: Array[PlayerAbilities.Ability] = []
@export var arrow_count: int = 0
@export var bomb_count: int = 0

#region save/load
func save_to_dict(s: SaveKitSerializer) -> Dictionary:
    var player: Player = PlayerManager.get_player()

    scene = ResourceUID.uid_to_path(SceneHelper.current_scene)
    pos = player.global_position
    hp = player.hp
    max_hp = player.max_hp
    level = player.level
    xp = player.xp
    base_atk = player.base_atk
    base_def = player.base_def
    abilities = player.abilities.abilities
    arrow_count = player.arrow_count
    bomb_count = player.bomb_count

    return super(s)

func load_from_dict(d: SaveKitDeserializer, data: Dictionary) -> void:
    super(d, data)
    SceneHelper.scene_to_load = ResourceUID.path_to_uid(scene)
#endregion
