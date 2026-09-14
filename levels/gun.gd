extends Node3D
class_name Gun

@export var barrels: Array[RayCast3D]
@export var callibre: int = 0
@export var cam_shoot: bool

var _last_shot_barrel: int

func shoot(ray: RayCast3D, speed: float) -> void:
    _last_shot_barrel += 1
    if barrels.is_empty():
        push_error("Gun has no barrel")
        return

    _last_shot_barrel %= barrels.size()
    if cam_shoot:
        _cam_shoot(barrels[_last_shot_barrel], ray, speed)
    else:
        _shoot(barrels[_last_shot_barrel], speed)

func _cam_shoot(barrel: RayCast3D, from: RayCast3D, speed) -> void:
    from.force_raycast_update()
    var origin: Vector3 = barrel.global_position
    var target: Vector3 = from.get_collision_point() if from.is_colliding() else from.to_global(from.target_position)
    var hit: Object = from.get_collider()
    SignalBus.on_shot.emit(callibre, speed, origin, target, hit)

func _shoot(from: RayCast3D, speed) -> void:
    from.force_raycast_update()
    var origin: Vector3 = from.global_position
    var target: Vector3 = from.get_collision_point() if from.is_colliding() else from.to_global(from.target_position)
    var hit: Object = from.get_collider()
    SignalBus.on_shot.emit(callibre, speed, origin, target, hit)
