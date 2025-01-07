class_name Inventory extends Node

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
#@export var weapons: Array[int]
@export var ammo_stock: Array[int]

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func init() -> void:
	if !is_multiplayer_authority(): return
	ammo_stock = []
	for i in Util.BULLET_DATABASE.database.size():
		ammo_stock.append(0)

# (({[%%%(({[=======================================================================================================================]}))%%%]}))
func drop_contents() -> void:
	pass
