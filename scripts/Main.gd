# res://scripts/Main.gd
extends Node

var current_game_scene: Node = null

func _ready():
	load_menu("res://ui/MainMenu.tscn")

func load_menu(path: String):
	clear_game_layer()
	var menu = load(path).instantiate()
	$MenuLayer.add_child(menu)

func start_game():
	load_game_scene("res://scenes/game/StrategicMap.tscn")

func load_game_scene(path: String):
	clear_game_layer()
	current_game_scene = load(path).instantiate()
	$GameLayer.add_child(current_game_scene)

func clear_game_layer():
	for child in $GameLayer.get_children():
		child.queue_free()
