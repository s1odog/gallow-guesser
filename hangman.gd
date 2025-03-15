extends Control

@onready var attempts_label = $attempts_left  # Label for attempts left
@onready var word_container = $WordContainer  # Container for individual letter labels
@onready var hangman_sprite = $Hangman_sprite  # Hangman sprite 
@onready var letters_container = $GridContainer_letters  # Container for alphabet letter buttons
@onready var timer = $Timer  # Timer
@onready var timer_label = $timer_label  # Timer abel
@onready var game_over_label = $game_over_label  # Label to display win/lose message
@onready var play_button = $Play_Single_Multi_Container/PlayButton
@onready var difficulty_checkboxes = {
	"2 Braincells": $DifficultiesContainer/TwoBraincellsCheckBox,
	"Noob": $DifficultiesContainer/NoobCheckBox,
	"Medium": $DifficultiesContainer/MediumCheckBox,
	"Veteran": $DifficultiesContainer/VeteranCheckBox,
	"200IQ": $DifficultiesContainer/TwoHundredIQCheckBox}
@onready var alphabet_normal_style = preload("res://play_box_style.tres")
@onready var alphabet_hover_style = preload("res://play_box_style_hover.tres")
@onready var alphabet_pressed_style = preload("res://play_box_style_pressed.tres")


# Game variables
var attempts_left = 8
var word_to_guess = {  # List of words to guess
	"2 Braincells": ["ME", "GO", "UP"],  # 2 letters
	"Noob": ["DEBUG", "DIVAS", "GROUP"],  # 3-5 letters
	"Medium": ["HANGMAN", "GALLOW", "GUESSER"],  # 6-7 letters
	"Veteran": ["COMPUTER", "UNIVERSITY", "ALGORITHM"],  # 8-10 letters
	"200IQ": ["RESPONSIBILITIES", "SYNCHRONIE", "CONGRATULATIONS"]  # 10+ letters
}


var selected_mode = ""  # Default mode when starting game
var chosen_word = ""  # The word selected for the current game
var guessed_letters = []  # List of guessed letters
var letter_buttons = {}  # Dictionary to store buttons


# Called when the scene is ready
func _ready():
	show_mode_selection()

	# Setting positions
	attempts_label.position = Vector2(50, 10)  # Position of attempts label
	word_container.position = Vector2(500, 300)  # Position of word container
	game_over_label.position = Vector2(400, 400)  # Position of game over label
	attempts_label.position = Vector2(700, 535)
	word_container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN #container is lefft aligned 
	
func show_mode_selection():
	# Show mode selection buttons
	$GameModesContainer/NormalModeButton.visible = true
	$GameModesContainer/TimedModeButton.visible = true

	letters_container.visible = false
	game_over_label.visible = false
	attempts_label.visible = false
	word_container.visible = false
	hangman_sprite.visible = false
	timer.stop()
	
	
var game_mode = "Normal"  # Default to normal mode

func _on_normal_mode_pressed():
	game_mode = "Normal"
	show_difficulty_selection()

func _on_timed_mode_pressed():
	game_mode = "Timed"
	show_difficulty_selection()
	
var time_left = 60  # Timer in seconds

func _on_Timer_timeout():
	if game_mode == "Timed":
		time_left -= 1
		timer_label.text = str(time_left)  # Update timer label
		if time_left <= 0:
			game_over("lose")  # Trigger game over when time runs out


# Show difficulty selection and hide everything else
func show_difficulty_selection():
	$DifficultiesContainer/TwoBraincellsCheckBox.visible = true
	$DifficultiesContainer/NoobCheckBox.visible = true
	$DifficultiesContainer/MediumCheckBox.visible = true
	$DifficultiesContainer/VeteranCheckBox.visible = true
	$DifficultiesContainer/TwoHundredIQCheckBox.visible = true
	play_button.visible = true
	
	# Hide other
	game_over_label.visible = false
	attempts_label.visible = false
	word_container.visible = false
	hangman_sprite.visible = false
	letters_container.visible = false
	timer.stop()


func start_game():
	if selected_mode in word_to_guess:
		var words_list = word_to_guess[selected_mode]  # Get the list of words
		chosen_word = words_list[randi() % words_list.size()]  # Pick a random word
	else:
		print("Error: Selected mode not found in word_to_guess dictionary")
		return  # Exit function if mode is invalid

	attempts_left = 8
	guessed_letters.clear()
	update_attempts_label()
	update_word_display()
	hangman_sprite.frame = 0  # Reset hangman sprite

	# Clear and recreate buttons
	letter_buttons.clear()
	for child in letters_container.get_children():
		child.queue_free()

	for letter in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
		var button = Button.new()
		button.text = letter
		button.add_theme_stylebox_override("normal", alphabet_normal_style)
		button.add_theme_stylebox_override("hover", alphabet_hover_style)
		button.add_theme_stylebox_override("pressed", alphabet_pressed_style)
		button.add_theme_color_override("font_color", Color(0, 0, 0)) #black font
		button.add_theme_color_override("font_hover_color", Color(0, 0, 0))
		button.add_theme_color_override("font_pressed_color", Color(0, 0, 0))
		button.pressed.connect(_on_letter_pressed.bind(letter))
		letters_container.add_child(button)
		letter_buttons[letter] = button  # Store reference

	# Starts the timer if Timed Mode is selected
	if game_mode == "Timed":
		time_left = 60  # Reset the timer to 60 seconds at the start of the game
		timer_label.show()
		timer_label.visible = true  # Make sure the timer label is visible
		timer.wait_time = 1
		timer.start()  # Start the countdown timer
	else:
		timer.stop()  # No timer in Normal Mode

	# Hide the Play button after starting the game
	play_button.visible = false
	game_over_label.visible = false

	# Show game UI
	timer_label.visible = true
	attempts_label.visible = true
	word_container.visible = true
	hangman_sprite.visible = true
	letters_container.visible = true

	print("Game has started!")


func change_game_mode(mode: String):
	if mode in word_to_guess:
		selected_mode = mode
		#start_game()


func _on_2braincells_checkbox_toggled(toggled_on):
	if toggled_on:
		uncheck_other_difficulties("2 Braincells")
		change_game_mode("2 Braincells")

func _on_noob_checkbox_toggled(toggled_on):
	if toggled_on:
		uncheck_other_difficulties("Noob")
		change_game_mode("Noob")

func _on_medium_checkbox_toggled(toggled_on):
	if toggled_on:
		uncheck_other_difficulties("Medium")
		change_game_mode("Medium")

func _on_veteran_checkbox_toggled(toggled_on):
	if toggled_on:
		uncheck_other_difficulties("Veteran")
		change_game_mode("Veteran")

func _on_200iq_checkbox_toggled(toggled_on):
	if toggled_on:
		uncheck_other_difficulties("200IQ")
		change_game_mode("200IQ")

func uncheck_other_difficulties(selected_difficulty: String):
	for difficulty in difficulty_checkboxes:
		if difficulty != selected_difficulty:
			difficulty_checkboxes[difficulty].button_pressed = false



# Updates the attempts label dynamically
func update_attempts_label():
	attempts_label.text = "Attempts left: " + str(attempts_left)


# Updates the word display with underscores for each unguessed letter
func update_word_display():
	for child in word_container.get_children():
		child.queue_free()
	for letter in chosen_word:
		var letter_label = Label.new()
		letter_label.text = letter if letter in guessed_letters else "_"
		letter_label.add_theme_font_size_override("font_size", 40)
		letter_label.add_theme_color_override("font_color", Color.BLACK)
		letter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		word_container.add_child(letter_label)


# Handles when a letter button is pressed
func _on_letter_pressed(letter):
	if letter in guessed_letters:
		return  # Ignore repeated guesses

	guessed_letters.append(letter)

	if letter in chosen_word:
		update_word_display()
	else:
		attempts_left -= 1
		update_attempts_label()
		update_hangman_sprite()

	letter_buttons[letter].disabled = true  # Disable button after use

	if attempts_left <= 0:
		game_over("lose")
	elif all_letters_guessed():
		game_over("win")


# Updates the hangman sprite (next frame)
func update_hangman_sprite():
	hangman_sprite.frame = 8 - attempts_left  # 8 frames for hangman drawing


# Checks if all letters have been guessed correctly
func all_letters_guessed() -> bool:
	for letter in chosen_word:
		if letter not in guessed_letters:
			return false
	return true


# Handles game over
func game_over(result):
	game_over_label.text = "You win! :D" if result == "win" else "You lose! :("
	for child in letters_container.get_children():
		child.disabled = true
	timer.stop()
	game_over_label.visible = true
	play_button.visible = true

func _on_play_button_pressed():
	if selected_mode != "":
		start_game()
	else:
		print("Please select a difficulty before starting the game.")

func _on_timer_timeout() -> void: #is duplicated with _on_Timer_timeout btw
	pass # Replace with function body.
