class_name Utils extends Object

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
