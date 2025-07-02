extends Control

func _on_Start_pressed():
	get_tree().root.get_node("Main").start_game()

func _on_Quit_pressed():
	get_tree().quit()

func _on_Settings_pressed():
	get_tree().root.get_node("Main").load_menu("res://scenes/ui/SettingsMenu.tscn")
