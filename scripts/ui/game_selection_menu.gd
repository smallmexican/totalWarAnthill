# ==============================================================================
# GAME SELECTION MENU
# ==============================================================================
# Purpose: Allow players to choose between different game modes
# 
# CURRENT STATUS: FUNCTIONAL - Campaign disabled, Skirmish available
# 
# FEATURES:
# - Campaign Mode button (disabled with "Coming Soon" tooltip)
# - Skirmish Mode button (functional - leads to Strategic Map)
# - Back to Main Menu option
# - Tooltips explaining each mode
#
# USAGE:
# - Accessed from Main Menu "Start Game" button
# - Skirmish Mode → Strategic Map (current gameplay)
# - Campaign Mode → Disabled until implemented
# - Back → Return to Main Menu
#
# NAVIGATION:
# - Campaign → (Disabled) "Coming Soon" tooltip
# - Skirmish → Skirmish Setup Menu (species/map/opponent selection)
# - Back → Main Menu
# ==============================================================================

extends Control

# ------------------------------------------------------------------------------
# MEMBER VARIABLES
# ------------------------------------------------------------------------------

## Reference to the main scene manager for transitions
var main_scene_manager: Node

# ------------------------------------------------------------------------------
# GODOT LIFECYCLE METHODS
# ------------------------------------------------------------------------------

## Initialize the game selection menu
func _ready():
	print("GameSelectionMenu: _ready() called")
	
	# Get reference to the main scene manager
	main_scene_manager = get_tree().root.get_node("Main")
	if main_scene_manager:
		print("GameSelectionMenu: main_scene_manager found: ", main_scene_manager.name)
	else:
		print("GameSelectionMenu: ERROR - main_scene_manager not found!")
	
	# Display game selection menu information
	print("=== GAME SELECTION MENU LOADED ===")
	print("Choose your game mode:")
	print("  Campaign - Coming Soon")
	print("  Skirmish - Available")

# ------------------------------------------------------------------------------
# INPUT HANDLING
# ------------------------------------------------------------------------------

## Handle input for game selection menu (ESC to go back)
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		print("ESC pressed in game selection menu - returning to main menu")
		_on_back_button_pressed()

# ------------------------------------------------------------------------------
# BUTTON SIGNAL HANDLERS
# ------------------------------------------------------------------------------

## Handle Campaign Mode button (currently disabled)
## @note: Placeholder for future campaign implementation
func _on_campaign_button_pressed() -> void:
	print("Campaign Mode clicked (disabled)")
	# This shouldn't be called since button is disabled, but just in case:
	print("Campaign Mode is not yet implemented - Coming Soon!")

## Handle Skirmish Mode button - opens skirmish setup menu
## @note: Leads to configuration screen before gameplay
func _on_skirmish_button_pressed() -> void:
	print("GameSelectionMenu: Skirmish Mode selected")
	print("Opening Skirmish Setup menu...")
	
	if main_scene_manager:
		# Load the Skirmish Setup menu for match configuration
		main_scene_manager.load_menu("res://scenes/ui/SkirmishSetupMenu.tscn")
	else:
		print("ERROR: main_scene_manager is null!")

## Handle Back button - return to main menu
## @note: Returns to the main menu without starting any game
func _on_back_button_pressed() -> void:
	print("GameSelectionMenu: Back button pressed")
	print("Returning to Main Menu...")
	
	if main_scene_manager:
		main_scene_manager.load_menu("res://ui/MainMenu.tscn")
	else:
		print("ERROR: main_scene_manager is null!")

# ------------------------------------------------------------------------------
# FUTURE IMPLEMENTATION METHODS (PLACEHOLDER STUBS)
# ------------------------------------------------------------------------------

## Start Campaign Mode (when implemented)
## TODO: Implement campaign mode with story progression
func start_campaign_mode():
	print("Starting Campaign Mode...")
	# TODO: Future implementation
	# - Load campaign selection screen
	# - Show available scenarios/chapters
	# - Track campaign progress
	# - Load appropriate campaign scene
	pass

## Show game mode information dialog
## TODO: Add detailed explanations of each mode
func show_mode_info(mode: String):
	print("Showing info for mode: ", mode)
	# TODO: Future implementation
	# - Show detailed mode descriptions
	# - Display features and objectives
	# - Show estimated play time
	pass

## Load saved campaign progress
## TODO: Integrate with save system for campaign continuation
func load_campaign_save():
	print("Loading campaign save...")
	# TODO: Future implementation
	# - Check for existing campaign saves
	# - Allow continuation from last checkpoint
	# - Show campaign progress
	pass
