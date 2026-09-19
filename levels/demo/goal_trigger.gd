extends Area3D

func _enter_tree() -> void:
    if area_entered.connect(_handle_player_enter) != OK:
        push_error("Failed to connect player enter")

func _handle_player_enter(body: Node3D) -> void:
    if PlayerCharacter.get_player_parent(body):
        SignalBus.on_end_level.emit(Time.get_ticks_msec())
        _reload.call_deferred()

func _reload() -> void:
    await get_tree().create_timer(3.0).timeout
    get_tree().reload_current_scene()
