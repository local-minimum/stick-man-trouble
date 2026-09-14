extends Node3D
class_name Enemy

@export var _ready_trigger: ProgressTrigger
@export var _ready_position: Node3D
@export var _ready_transition_duration: float = 0.5

var alive: bool = true

func _enter_tree() -> void:
    if SignalBus.on_hit.connect(_handle_hit) != OK:
        push_error("Failed to connect handle hit")
    if _ready_trigger && _ready_trigger.on_player_enter.connect(_handle_ready) != OK:
        push_error("Failed to connect handle ready")

func _handle_ready(_player: PlayerCharacter) -> void:
    if !alive:
        return

    if !_ready_position:
        push_warning("No movement to ready")

    var t: Tween = create_tween()
    t.tween_property(self, "global_position", _ready_position.global_position, _ready_transition_duration)

func _handle_hit(enemy: Enemy, _callibre: int) -> void:
    if enemy != self || !alive:
        return

    alive = false
    queue_free()


static func get_enemy_parent(n: Node) -> Enemy:
    while n:
        if n is Enemy:
            return n as Enemy
        n = n.get_parent()

    return null
