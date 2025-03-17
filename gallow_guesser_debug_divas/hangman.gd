extends Control

@onready var attempts_label = $attempts_left  # Label for attempts left
@onready var word_container = $WordContainer  # Container for individual letter labels
@onready var hangman_sprite = $Hangman_sprite  # Hangman sprite 
@onready var letters_container = $GridContainer_letters  # Container for alphabet letter buttons
@onready var timer = $Timer  # Timer
@onready var timer_label = $timer_label  # Timer abel
@onready var game_over_label = $game_over_label  # Label to display win/lose message
var game_mode = "Timed"


# Game variables
var attempts_left = 8
var word_to_guess = {  # List of words to guess
	"2 Braincells": ["ME", "GO", "UP"],  # 2 letters
	"Noob": ["DEBUG", "DIVAS", "GROUP"],  # 3-5 letters
	"Medium": ["HANGMAN", "GALLOW", "GUESSER"],  # 6-7 letters
	"Veteran": ["COMPUTER", "UNIVERSITY", "ALGORITHM"],  # 8-10 letters
	"200IQ": ["RESPONSIBILITIES", "SYNCHRONIZE", "CONGRATULATIONS"]  # 10+ letters
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
	word_container.position = Vector2(200, 400)  # Position of word container
	game_over_label.position = Vector2(400, 400)  # Position of game over label
	timer_label.position = Vector2(800, 50)
	
func show_mode_selection():
	# Show mode selection buttons
	$ButtonContainer/GameModesContainer/NormalModeButton.visible = true
	$ButtonContainer/GameModesContainer/TimedModeButton.visible = true
	
	# Hide difficulty buttons initially
	$ButtonContainer/DifficultiesContainer/TwoBraincellsButton.visible = false
	$ButtonContainer/DifficultiesContainer/NoobButton.visible = false
	$ButtonContainer/DifficultiesContainer/MediumButton.visible = false
	$ButtonContainer/DifficultiesContainer/VeteranButton.visible = false
	$ButtonContainer/DifficultiesContainer/TwoHundredIQButton.visible = false
	
	game_over_label.visible = false
	attempts_label.visible = false
	word_container.visible = false
	hangman_sprite.visible = false
	timer.stop()
	
	


func _on_normal_mode_pressed():
	game_mode = "Normal"
	show_difficulty_selection()

func _on_timed_mode_pressed():
	game_mode = "Timed"
	show_difficulty_selection()
	
var time_left = 60  # Timer in seconds

func _on_timer_timeout():
	if game_mode == "Timed":
		timer_label.z_index = 10
		time_left -= 1
		timer_label.text = str(time_left)  # Update timer label
		timer_label.visible = true
		if time_left <= 0:
			game_over("lose")  # Trigger game over when time runs out


# Show difficulty selection and hide everything else
func show_difficulty_selection():
	$ButtonContainer/DifficultiesContainer/TwoBraincellsButton.visible = true
	$ButtonContainer/DifficultiesContainer/NoobButton.visible = true
	$ButtonContainer/DifficultiesContainer/MediumButton.visible = true
	$ButtonContainer/DifficultiesContainer/VeteranButton.visible = true
	$ButtonContainer/DifficultiesContainer/TwoHundredIQButton.visible = true
	
	# Hide other buttons
	$ButtonContainer/GameModesContainer/NormalModeButton.visible = false
	$ButtonContainer/GameModesContainer/TimedModeButton.visible = false
	game_over_label.visible = false
	attempts_label.visible = false
	word_container.visible = false
	hangman_sprite.visible = false
	timer.stop()


func start_game():
	
	if game_mode != "Timed":
		return
	
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
		button.pressed.connect(_on_letter_pressed.bind(letter))
		letters_container.add_child(button)
		letter_buttons[letter] = button  # Store reference

	timer_label.text = str(time_left)
	


	time_left = 60  # Reset the timer to 60 seconds at the start of the game
	timer_label.show()
	timer_label.visible = true  # Make sure the timer label is visible
	timer.wait_time = 1
	timer.start()  # Start the countdown timer
	
	# Hide difficulty selection and show game UI
	$ButtonContainer/DifficultiesContainer/TwoBraincellsButton.visible = false
	$ButtonContainer/DifficultiesContainer/NoobButton.visible = false
	$ButtonContainer/DifficultiesContainer/MediumButton.visible = false
	$ButtonContainer/DifficultiesContainer/VeteranButton.visible = false
	$ButtonContainer/DifficultiesContainer/TwoHundredIQButton.visible = false
	timer_label.visible = true
	attempts_label.visible = true
	word_container.visible = true
	hangman_sprite.visible = true


	print("Game has started!")


func change_game_mode(mode: String):
	if mode in word_to_guess:
		selected_mode = mode
		start_game()


func _on_2braincells_button_pressed():
	change_game_mode("2 Braincells")

func _on_noob_button_pressed():
	change_game_mode("Noob")

func _on_medium_button_pressed():
	change_game_mode("Medium")

func _on_veteran_button_pressed():
	change_game_mode("Veteran")

func _on_200iq_button_pressed():
	change_game_mode("200IQ")


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
