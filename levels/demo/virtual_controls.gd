extends MarginContainer

func _ready() -> void:
    if !CrossHair.DEBUG_TOUCH && not OS.has_feature("web_android") && not OS.has_feature("web_ios"):
        visible = false
