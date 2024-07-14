extends GraphEdit

var _db_context_menu: PopupMenu = null


func _ready():
    _db_context_menu = PopupMenu.new()
    add_child(_db_context_menu)

    for category in ["foo", "bar"]:
        var sub_menu: PopupMenu = PopupMenu.new()
        sub_menu.id_pressed.connect(_on_context_menu_item_selected)

        for i in range(5):
            sub_menu.add_item("Item " + str(i), 10 * i)

        _db_context_menu.add_child(sub_menu)
        _db_context_menu.add_submenu_item(category, sub_menu.name)
        
func _on_popup_request(position):
    var viewport_mouse_position: Vector2 = get_viewport().get_mouse_position()

    # Bring up the context menu containing instructions
    _db_context_menu.position = viewport_mouse_position
    _db_context_menu.popup()

func _on_context_menu_item_selected(id: int) -> void:
    print("Id selected: " + str(id))
