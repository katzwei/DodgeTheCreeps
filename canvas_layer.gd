extends CanvasLayer


signal start_game
signal input_submit(input_text)
signal use_power


func show_message(text, phase_out = true):
	$ScoreLabel.hide()
	$Message.text = text
	$Message.show()
	if phase_out:
		$MessageTimer.start()
	await get_tree().create_timer(1.0).timeout


func show_leaderboard(text):
	$Leaderboard.text = text
	$Leaderboard.show()


func show_game_over():
	show_message("Game Over")
	$PowerUI/PowerButton/PowerGauge.value = 0
	$PowerUI.hide()
	$GameOverInput.show()


func update_score(score):
	$ScoreLabel.text = str(score)


func _on_message_timer_timeout():
	$Message.hide()
	$ScoreLabel.show()


func _on_start_button_pressed():
	$StartButton.hide()
	$Leaderboard.hide()
	$PowerUI.show()
	start_game.emit()



func _on_input_submit_pressed():
	input_submit.emit($GameOverInput/InputField.text)
	$GameOverInput.hide()
	show_message("Dodge the Creeps!", false)
	$StartButton.show()


func _on_input_randomize_pressed():
	var random_names = ["Goofbal", "Scrunkly", "iLoveDp", "xX_DarkDestroyer_Xx"]
	$GameOverInput/InputField.text = random_names[randi_range(0, random_names.size() - 1)]
	_on_input_field_text_changed($GameOverInput/InputField.text)


func _on_input_field_text_changed(new_text):
	$GameOverInput/InputSubmit.disabled = new_text == ''


func try_use_power():
	if $PowerUI/PowerButton/PowerGauge.value == $PowerUI/PowerButton/PowerGauge.max_value:
		use_power.emit()


func _on_power_button_pressed():
	try_use_power()

