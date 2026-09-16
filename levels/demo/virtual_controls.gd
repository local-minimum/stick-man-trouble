extends MarginContainer

func _ready() -> void:
    if not OS.has_feature("web_android") and not OS.has_feature("web_ios"):
        visible = false

func _input(event: InputEvent) -> void:
    if event.is_action("nothing"):
        print_debug(event.get_action_strength("nothing"))
