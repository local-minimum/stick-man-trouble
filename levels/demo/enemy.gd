extends Node3D
class_name Enemy

static var AIM_ASSIST_LAYER: int = 32
@export var player: PlayerCharacter
@export var _ready_trigger: ProgressTrigger
@export var _ready_position: Node3D
@export var _ready_transition_duration: float = 0.5
@export var body: StaticBody3D
@export var collision_factor: float = 0.2
@export var collision_shake_factor: float = 0.5
@export var gun: EnemyGun

var alive: bool = true
var catapulting: bool

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
    if gun:
        gun.abort_aim()

    SignalBus.on_remove_aim.emit(gun.eyes)
    queue_free()

func collide(trajectory: Vector3) -> void:
    alive = false
    catapulting = true
    var t: Tween = create_tween()
    t.tween_property(self, "global_position", global_position + trajectory, 0.3)
    t.finished.connect(queue_free)


func _process(_delta: float) -> void:
    if !alive:
        return

    if player.is_beyond(self):
        alive = false

    if gun:
        if gun.phase == EnemyGun.Phase.HELD && gun.sees(player.aim_target):
            gun.target_locked.connect(_handle_shoot, CONNECT_ONE_SHOT)
            gun.aim(player.aim_target)


func _handle_shoot() -> void:
    SignalBus.on_aim.emit(gun.eyes, player, 0.0)
    player.hit()
    await get_tree().create_timer(0.2).timeout
    SignalBus.on_remove_aim.emit(gun.eyes)
    await get_tree().create_timer(0.1).timeout
    gun.phase = EnemyGun.Phase.HELD

static func get_enemy_parent(n: Node) -> Enemy:
    while n:
        if n is Enemy:
            return n as Enemy
        n = n.get_parent()

    return null
