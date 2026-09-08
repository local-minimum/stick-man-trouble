extends Node3D
class_name Enemy

var alive: bool = true

func _on_static_body_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
    if event.is_action_pressed(&"player_shoot"):
        alive = false
        queue_free()
