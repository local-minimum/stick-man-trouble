extends Area3D


func _enter_tree() -> void:
    if area_entered.connect(_handle_player_enter) != OK:
        push_error("Failed to connect player enter")

func _handle_player_enter(body: Node3D) -> void:
    if PlayerCharacter.get_player_parent(body):
        _reload.call_deferred()

func _reload() -> void:
        get_tree().reload_current_scene()
