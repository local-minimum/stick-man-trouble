extends MarginContainer

func _is_touch_device() -> bool:
    return OS.has_feature("web_android") || OS.has_feature("web_ios")

func _ready() -> void:
    if !CrossHair.DEBUG_TOUCH && !_is_touch_device():
        visible = false
