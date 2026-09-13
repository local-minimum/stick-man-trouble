extends Node3D
class_name Enemy

var alive: bool = true

func _enter_tree() -> void:
    if SignalBus.on_hit.connect(_handle_hit) != OK:
        push_error("Failed to connect handle hit")

func _handle_hit(enemy: Enemy) -> void:
    if enemy != self || !alive:
        return

    alive = false
    queue_free()
