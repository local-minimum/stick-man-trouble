extends MeshInstance3D
class_name EnemyGun

signal target_locked

@export var lock_duration: float = 1.0
@export var inital_aim_width: float = 1.5
@export var weapon_range: float = 40.0
@export var aim_left: Line3D
@export var aim_right: Line3D
@export var eyes: RayCast3D


enum Phase { HELD, AIMING, AIMED, SHOOTING }
var phase: Phase = Phase.HELD

func _update_aims(progress: float) -> void:
    var right: Vector3 = _target.global_basis.x
    var delta: Vector3 =  right * inital_aim_width * 0.5 * (1.0 - progress)

    aim_left.clear_points()
    aim_left.add_global_point(aim_left.global_position)
    aim_left.add_global_point(_target.global_position - delta)

    aim_right.clear_points()
    aim_right.add_global_point(aim_right.global_position)
    aim_right.add_global_point(_target.global_position + delta)

var _target: Node3D
var aim_tween: Tween

func aim(target: Node3D) -> void:
    if phase == Phase.AIMING:
        aim_tween.kill()

    phase = Phase.AIMING
    _target = target

    _update_aims(0.0)
    aim_left.visible = true
    aim_right.visible = true

    aim_tween = create_tween()
    aim_tween.tween_method(_update_aims, 0.0, 1.0, lock_duration)
    aim_tween.finished.connect(
        func () -> void:
            phase = Phase.AIMED
            target_locked.emit()
            aim_left.visible = false
            aim_right.visible = false
            ,
    )

func sees(target: Node3D) -> bool:
    if target.global_position.distance_to(global_position) > weapon_range:
        return false

    eyes.target_position = eyes.to_local(target.global_position)
    eyes.force_raycast_update()

    if !eyes.is_colliding():
        return false

    return PlayerCharacter.get_player_parent(eyes.get_collider()) != null

static func _is_parent(node: Node, child: Node) -> bool:
    while child != null:
        if child == node:
            return true
        child = child.get_parent()
    return false
