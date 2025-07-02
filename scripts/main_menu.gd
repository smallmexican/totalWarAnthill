extends Control

func _on_start_button_pressed() -> void:
	get_tree().root.get_node("Main").start_game()


func _on_settings_button_pressed() -> void:
	get_tree().root.get_node("Main").load_menu("res://scenes/ui/SettingsMenu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
