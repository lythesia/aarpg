class_name BalloonPortait extends TextureRect

enum Emotion {
    # frame 0
    NORMAL,
    # frame 1
    EYES_CLOSED,
    # frame 2
    SPEAKING,
    # frame 3
    EYES_CLOSED_SPEAKING,
}
const WIDTH: int = 100
const HEIGHT: int = 148

func set_portrait(char_name: String, emo: Emotion):
    texture = _get_portrait_path(char_name, emo)

func _get_portrait_path(char_name: String, emo: Emotion) -> AtlasTexture:
    var path: String = "res://gui/dialogue_system/portrait_res/%s.tres" % char_name
    assert(ResourceLoader.exists(path))
    var at: AtlasTexture = load(path)
    at.region.position.x = WIDTH * int(emo)
    return at
