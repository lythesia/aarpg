class_name Utils extends Object

const CLOCKWISE: Array[Vector2] = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]

## tell if the node is editing its own scene (not as an instance)
static func is_editing_own_scene(node: Node) -> bool:
    if not node or not Engine.is_editor_hint():
        return false

    # get the root node of the scene that is being edited
    var edited_root := EditorInterface.get_edited_scene_root()
    if not edited_root:
        return false

    # approach 2: if you want to be more strict, only check if the node is the root node of the edited scene
    return node == edited_root or node.get_parent() == null

## calculate the cardinal direction of the velocity direction
static func calc_cardinal_dir(vel_dir: Vector2) -> Vector2:
    # cleaver! and give honor to original cardinal direction
    var idx = round((vel_dir.angle() / TAU) * 4)
    return CLOCKWISE[idx]

## calculate the cardinal direction of the velocity direction, biased by the current cardinal direction
static func calc_cardinal_dir_biased(vel_dir: Vector2, current_cardinal_dir: Vector2) -> Vector2:
    var idx = round(((vel_dir + 0.1 * current_cardinal_dir).angle() / TAU) * 4)
    return CLOCKWISE[idx]

## convert the cardinal direction to the animation suffix
static func cardinal_dir_to_anim_suffix(dir: Vector2) -> String:
    match dir:
        Vector2.UP:
            return "up"
        Vector2.DOWN:
            return "down"
        _:
            return "side"
