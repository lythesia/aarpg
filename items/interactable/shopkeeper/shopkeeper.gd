class_name Shopkeeper extends Node2D

const SHOP_MENU: PackedScene = preload("uid://duuphn430tnui")

@export var shop_inventory: Array[ItemData]

func show_shop_menu() -> void:
    var shop_menu = SHOP_MENU.instantiate()
    get_tree().current_scene.add_child(shop_menu)
    shop_menu.open_menu(shop_inventory)
