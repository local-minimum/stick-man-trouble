extends Area3D
class_name PlayerCharacter

@export var cam: Camera3D
@export var gun_arm: Node3D
@export var max_speed: float = 20.0
@export var min_speed: float = 1.0
@export var acceleration: float = 1.0
@export var lateral_speed_factor: float = 5.0
@export var road_direction: Vector3 = Vector3(0.0, 0.0, -1.0)
@export var road_right: Vector3 = Vector3(1.0, 0.0, 0.0)
@export var road_width: float = 6.0
@export var road_overshoot: float = -1.0
@export var aim_ray: RayCast3D
@export var aim_distance: float = 250
@export var aim_assist_checks: int = 3
@export var shake_magnitude: float = 0.1
@export var shake_duration: float = 0.4

@export var gun: Gun

var aim_assist: bool:
    get():
        return CrossHair.mode == CrossHair.InputMode.CONTROLLER

var _road_position: Vector3
var _speed: float = 0.0
var _lateral_speed: float = 0.0
var _paused: bool
var _shake_time: float
var _shake_factor: float

func is_paused() -> bool:
    return _paused

func _enter_tree() -> void:
    if body_entered.connect(_handle_collide_body) != OK:
        push_error("Failed to connect body collision")

func _input(event: InputEvent) -> void:

    if event.is_action_pressed(&"pause"):
        _paused = !_paused
    if event.is_action_pressed(&"player_shoot"):
        if !_paused:
            gun.shoot(aim_ray, _speed)

func _check_input() -> void:
    if Input.is_action_pressed(&"player_left"):
        _lateral_speed = -Input.get_action_strength(&"player_left")
    elif Input.is_action_just_released(&"player_left") && _lateral_speed < 0:
        _lateral_speed = 0.0

    if Input.is_action_pressed(&"player_right"):
        _lateral_speed = Input.get_action_strength(&"player_right")
    elif Input.is_action_just_released(&"player_right") && _lateral_speed > 0:
        _lateral_speed = 0.0

func _process(delta: float) -> void:
    _check_input()

    if _paused:
        return

    _shake(delta)

    _set_current_road_position()

    # Update speed
    _speed += acceleration * delta
    if _speed > max_speed:
        _speed = max_speed

    if _lateral_speed != 0:
        var lateral: Vector3 = global_position - _road_position
        lateral += lateral_speed_factor * _lateral_speed * delta * road_right
        lateral = lateral.limit_length(road_width * 0.5 + road_overshoot)
        global_position = _road_position + lateral + _speed * road_direction * delta
    else:
        global_position += _speed * road_direction * delta

    if CrossHair.mode == CrossHair.InputMode.CONTROLLER && Time.get_ticks_msec() - gun.last_shot > 200:
        gun.shoot(aim_ray, _speed)

func _shake(delta: float) -> void:
    if _shake_time <= 0.0:
        return

    _shake_time -= delta
    if _shake_time <= 0.0:
        _shake_time = 0.0
        cam.position = Vector3.ZERO
        return

    var d: float = _shake_factor * shake_magnitude
    cam.position = cam.position.lerp(Vector3(randf_range(-d, d), randf_range(-d, d), randf_range(-d, d)), 0.7)

func _handle_collide_body(body: Node3D) -> void:
    var e: Enemy = Enemy.get_enemy_parent(body)
    if e == null || e.catapulting:
        return

    var delta: float = max_speed * e.collision_factor
    _speed = maxf(min_speed, _speed - delta)
    var direction: Vector3 = (e.global_position - global_position)
    direction.y = 1
    direction.normalized()
    e.collide(direction * _speed)
    _shake_time = shake_duration
    _shake_factor = e.collision_shake_factor

func _set_current_road_position():
    # This is a bit of a hack
    _road_position = global_position
    _road_position.x = 0

func aim_crosshair(pos: Vector2) -> Vector2:
    _aim_cast_pos(pos)

    if aim_assist:
        var hit_info: Dictionary
        if _aim_assist(hit_info):
            var pt3: Vector3 = lerp(hit_info[HitInfoField.POINT], hit_info[HitInfoField.ENEMY].global_position, 0.8)
            var pt: Vector2 = cam.unproject_position(pt3)
            _aim_cast_pos(pt)
            if aim_ray.is_colliding() && Enemy.get_enemy_parent(aim_ray.get_collider()) != null:
                pos = pt

    gun_arm.rotation_degrees.x = clampf(gun_arm.rotation_degrees.x, -10.0, 30.0)
    return pos

enum HitInfoField { ENEMY, POINT }

func _aim_cast_pos(pos: Vector2) -> void:
    var ray_origin: Vector3 = cam.project_ray_origin(pos)
    var ray_normal: Vector3 = cam.project_ray_normal(pos)
    aim_ray.global_position = ray_origin
    aim_ray.target_position = aim_ray.to_local(ray_origin + ray_normal * aim_distance)
    aim_ray.force_raycast_update()
    if aim_ray.is_colliding():
        gun_arm.look_at(aim_ray.get_collision_point())
    else:
        gun_arm.look_at(ray_origin + ray_normal * aim_distance)

func _aim_assist(hit_info: Dictionary) -> bool:
    aim_ray.set_collision_mask_value(Enemy.AIM_ASSIST_LAYER, true)

    var points: Array[Vector3]
    var targets: Array[Enemy]

    while points.size() < aim_assist_checks:
        aim_ray.force_raycast_update()
        if !aim_ray.is_colliding():
            break

        var col: Object = aim_ray.get_collider()

        if col is CollisionObject3D:
            aim_ray.add_exception(col)
            var target: Enemy = Enemy.get_enemy_parent(col)
            if !targets.has(target):
                targets.append(target)
                points.append(aim_ray.get_collision_point())

        else:
            break

    aim_ray.clear_exceptions()
    aim_ray.set_collision_mask_value(Enemy.AIM_ASSIST_LAYER, false)

    if targets.is_empty():
        return false

    var _best: int = -1
    var _best_dist_sq: float = -1
    var _best_pt: Vector3

    for i: int in targets.size():
        var enemy: Enemy = targets[i]
        var pt: Vector3 = points[i]
        if enemy == null:
            continue

        for col_shape: CollisionShape3D in enemy.body.find_children("", "CollisionShape3D", false):
            if col_shape.shape is BoxShape3D:
                var box: BoxShape3D = col_shape.shape
                var box_start: Vector3 = col_shape.to_global(-0.5 * box.size)
                var box_end: Vector3 = col_shape.to_global(0.5 * box.size)
                var closest: Vector3 = closest_box_surface_point(box_start, box_end, pt)
                var dist_sq: float = closest.distance_squared_to(pt)
                if _best < 0 || dist_sq < _best_dist_sq:
                    _best = i
                    _best_dist_sq = dist_sq
                    _best_pt = closest

    if _best < 0:
        return false

    hit_info[HitInfoField.ENEMY] = targets[_best]
    hit_info[HitInfoField.POINT] = _best_pt
    return true


static func closest_box_surface_point(start: Vector3, end: Vector3, point: Vector3) -> Vector3:
    return Vector3(
        clampf(point.x, start.x, end.x),
        clampf(point.y, start.y, end.y),
        clampf(point.z, start.z, end.z),
    )


static func get_player_parent(n: Node) -> PlayerCharacter:
    while n:
        if n is PlayerCharacter:
            return n as PlayerCharacter
        n = n.get_parent()

    return null
