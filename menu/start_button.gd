extends TextureButton

@export_file("*.tscn") var level: String

var _size_tween: Tween

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("player_shoot") && event is InputEventJoypadButton:
        _on_pressed()

func _on_mouse_entered() -> void:
    if _size_tween && _size_tween.is_running():
        _size_tween.kill()

    _size_tween = create_tween()
    _size_tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.2)

func _on_mouse_exited() -> void:
    if _size_tween && _size_tween.is_running():
        _size_tween.kill()

    _size_tween = create_tween()
    _size_tween.tween_property(self, "scale", Vector2(0.6, 0.6), 0.6)


func _on_pressed() -> void:
    get_tree().change_scene_to_file(level)
