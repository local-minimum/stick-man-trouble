extends Node3D

@export var a: Node3D
@export var b: Node3D
@export var line: Line3D


func _process(_delta: float) -> void:
    line.set_global_point(a.global_position, 0)
    line.set_global_point(b.global_position, 1)
