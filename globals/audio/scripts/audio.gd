extends Node

@export var ui_focus_audio: AudioStream
@export var ui_select_audio: AudioStream
@export var ui_cancel_audio: AudioStream
@export var ui_success_audio: AudioStream
@export var ui_error_audio: AudioStream

@onready var ui: AudioStreamPlayer = %UI
var ui_audio_player: AudioStreamPlaybackPolyphonic

func _ready() -> void:
    # play ui audio first to activate `AudioStreamPlaybackPolyphonic` (coz we config it)
    ui.play()
    ui_audio_player = ui.get_stream_playback()

func setup_button_audio(node: Node) -> void:
    for c in node.find_children("*Btn", "Button"):
        (c as Button).focus_entered.connect(ui_focus_change)
        (c as Button).pressed.connect(ui_select)

    for c in node.find_children("*Slider", "HSlider"):
        (c as HSlider).focus_entered.connect(ui_focus_change)

func play_ui_audio(audio: AudioStream) -> void:
    if ui_audio_player:
        ui_audio_player.play_stream(audio)

#region ui_audio
func ui_focus_change() -> void:
    play_ui_audio(ui_focus_audio)

func ui_select() -> void:
    play_ui_audio(ui_select_audio)

func ui_cancel() -> void:
    play_ui_audio(ui_cancel_audio)

func ui_success() -> void:
    play_ui_audio(ui_success_audio)

func ui_error() -> void:
    play_ui_audio(ui_error_audio)
#endregion :ui audio


func play_spatial_sound(audio: AudioStream, pos: Vector2, pitch_scale: float = 1.0) -> void:
    var player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
    add_child(player)
    player.bus = "SFX"
    player.global_position = pos
    player.stream = audio
    player.pitch_scale = pitch_scale
    player.finished.connect(player.queue_free)
    player.play()
