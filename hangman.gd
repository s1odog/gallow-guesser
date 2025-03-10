extends Control

@onready var attempts_label = $attempts_left  # Label for attempts left
@onready var word_container = $WordContainer  # Container for individual letter labels
@onready var hangman_sprite = $Hangman_sprite  # Hangman sprite 
@onready var letters_container = $GridContainer_letters  # Container for alphabet letter buttons
@onready var timer = $Timer  # Timer
@onready var game_over_label = $game_over_label  # Label to display win/lose message

# Game variables
var attempts_left = 8
var word_to_guess = ["HANGMAN", "GALLOW", "GUESSER", "DEBUG", "DIVAS"]  # List of words to guess
var chosen_word = ""  # The word selected for the current game
var guessed_letters = []  # List of guessed letters

# Called when the scene is ready
func _ready():
	# Starts game and set up UI
	start_game()

	# Setting positions
	attempts_label.position = Vector2(50, 10)  # Position of attempts label
	word_container.position = Vector2(200, 400) # Position of word container
	game_over_label.position = Vector2(400, 400) # Position of word containe

var letter_buttons = {}  # Dictionary to store buttons

func start_game():
	# Choose a random word from the list
	chosen_word = word_to_guess[randi() % word_to_guess.size()]
	attempts_left = 8
	guessed_letters.clear()  # Clears previous guesses for new game
	update_attempts_label()   # Update attempts left text wfor new game
	update_word_display()     # Update the word display with blanks for new game

	# Resets hangman sprite to oriuganal state
	hangman_sprite.frame = 0  

	# Starts the timer
	timer.start()

# Clear existing buttons in the letters container (in case they exist)
	for child in letters_container.get_children():
		child.queue_free()

# Create a button for each letter of the alphabet
	for letter in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
		var button = Button.new()
		button.text = letter
		button.pressed.connect(_on_letter_pressed.bind(letter))  # Corrected line
		letters_container.add_child(button)

	print("Game has started!")

# Updates the attempts label dynamically
func update_attempts_label():
	attempts_label.text = "Attempts left: " + str(attempts_left)

# Updates the word display with underscores for each unguessed letter
func update_word_display():
	# Clear previous letter labels
	for child in word_container.get_children():
		child.queue_free()
		
	# Create a label for each letter in chosen_word
	for letter in chosen_word:
		var letter_label = Label.new()
		letter_label.text = letter if letter in guessed_letters else "_"
		letter_label.add_theme_font_size_override("font_size", 40)
		word_container.add_child(letter_label)

# Handles when a letter button is pressed
func _on_letter_pressed(letter):
	if letter in guessed_letters:
		return  # Ignores if the letter has already been guessed

	guessed_letters.append(letter)

	if letter in chosen_word:
		update_word_display()  # Updates the word display with the correct guesses
	else:
		attempts_left -= 1
		update_attempts_label()  # Updates the attempts left
		update_hangman_sprite()  # Updates hangman sprite for wrong guesses

	# Disables the button after it's clicked to prevent guessing again
	if letter in letter_buttons:
		letter_buttons[letter].disabled = true

	# Checks if the game is over
	if attempts_left <= 0:
		game_over("lose")
	elif all_letters_guessed():
		game_over("win")

# Updates the hangman sprite (next frame)
func update_hangman_sprite():
	hangman_sprite.frame = 8 - attempts_left  # 8 frames to the hangman drawing

# Checks if all letters have been guessed correctly
func all_letters_guessed() -> bool:
	for letter in chosen_word:
		if letter not in guessed_letters:
			return false
	return true

# Handles game over (win or lose)
func game_over(result):
	if result == "win":
		game_over_label.text = "You win! :D"  # Display win message
	else:
		game_over_label.text = "You lose! :("  # Display lose message
	
	# Disable all buttons after the game ends
	for child in letters_container.get_children():
		child.disabled = true

	# Optionally reset the game after some time or allow for restart
	timer.stop()
