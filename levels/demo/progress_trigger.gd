extends Area3D
class_name ProgressTrigger

signal on_player_enter(player: PlayerCharacter)

var _fired: bool

func _enter_tree() -> void:
    if area_entered.connect(_handle_check_player) != OK:
        push_error("Failed ton connect area entered")
    if body_entered.connect(_handle_check_player) != OK:
        push_error("Failed to connect body entered")

func _handle_check_player(node: Node3D) -> void:
    if _fired:
        return

    var player: PlayerCharacter = PlayerCharacter.get_player_parent(node)
    if player:
        on_player_enter.emit(player)
        _fired = true
