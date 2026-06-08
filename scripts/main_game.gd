extends Control

@onready var chat_display: RichTextLabel = $Panel/ChatDisplay
@onready var button_1: Button = $Panel/HBoxContainer/OptionButton1
@onready var button_2: Button = $Panel/HBoxContainer/OptionButton2
@onready var money_label: Label = $Panel/MoneyLabel
@onready var timer: Timer = $Panel/Timer
@onready var timerLabel: Label = $Panel/TimerLabel

var minutes = timeLeft / 60
var secs = timeLeft % 60
var questions = preload("res://scripts/questions.gd").QUESTIONS
var timeLeft := questions.size() * 10

var typing_time := 1.0
var typing_progress := 0.0
var full_text := ""

func _ready() -> void:
	update_ui()
	show_current_question()
	button_1.pressed.connect(_on_button_1_pressed)
	button_2.pressed.connect(_on_button_2_pressed)
	timer.wait_time = 1.0
	timer.timeout.connect(_on_timer_timeout)
	timerLabel.text = "%02d:%02d" % [minutes, secs]
	await get_tree().create_timer(2).timeout
	timer.start()
	
func type_text(text_to_show: String):
	full_text = text_to_show
	chat_display.text = full_text
	chat_display.visible_characters = 0
	typing_progress = 0.0
	$Sounds/typingSound.play()

func show_current_question() -> void:
	if GameManager.player_penalties >= 3:
		chat_display.text = "🚨 СИСТЕМА: ВАС ЗВІЛЬНЕНО!\n\nВи допустили забагато помилок (3 штрафи). Шеф заблокував вашу перепустку."
		_end_game_state()
		timer.stop()
		return

	if GameManager.current_question_index < questions.size():
		var q = questions[GameManager.current_question_index]
		type_text(q["text"])
		button_1.text = q["opt1"]
		button_2.text = q["opt2"]
	else:
		if GameManager.player_money >= 0:
			chat_display.text = "🎉 ЗМІНУ ЗАВЕРШЕНО УСПІШНО!\n\nВи чудовий оператор ШІ. Шеф задоволений вашою роботою.\nВаш чистий заробіток: " + str(GameManager.player_money) + " $"
		else:
			chat_display.text = "😐 ЗМІНУ ЗАВЕРШЕНО...\n\nАле ви закінчили день у мінусі. Старайтеся краще наступного رازом."
		_end_game_state()
		$Sounds/victorySound.play()
		timer.stop()

func _on_button_1_pressed() -> void:
	check_answer(1)

func _on_button_2_pressed() -> void:
	check_answer(2)
	


func check_answer(player_choice: int) -> void:
	var q = questions[GameManager.current_question_index]
	
	print("--- ПЕРЕВІРКА ВІДПОВІДІ ---")
	print("Питання №: ", GameManager.current_question_index + 1)
	print("Вибір гравця: Кнопка ", player_choice, " | Правильна кнопка: ", q["correct"])
	
	if player_choice == q["correct"]:
		GameManager.player_money += q["reward"]
		print("Результат: ПРАВИЛЬНО! Нараховано +", q["reward"], " $")
		$Sounds/successSound.play()
	else:
		GameManager.player_money -= q["penalty"]
		GameManager.player_penalties += 1
		print("Результат: ПОМИЛКА! Штраф -", q["penalty"], " $ | Всього штрафів: ", GameManager.player_penalties)
		$Sounds/failSound.play()
	
	GameManager.current_question_index += 1
	print("Стан гри: Перехід до наступного індексу: ", GameManager.current_question_index)
	print("--------------------------")
	
	update_ui()
	show_current_question()

func update_ui() -> void:
	money_label.text = "Баланс: " + str(GameManager.player_money) + " $ | Штрафи: " + str(GameManager.player_penalties)

func _end_game_state() -> void:
	button_1.visible = false
	button_2.visible = false

func _on_timer_timeout():
	timeLeft -= 1
	minutes = timeLeft / 60
	secs = timeLeft % 60
	
	timerLabel.text = "%02d:%02d" % [minutes, secs]

	$Sounds/tickSound.play()

	if timeLeft <= 0:
		$Sounds/failSound.play()
		timer.stop()
		print("Час вийшов!")
		_end_game_state()
		chat_display.text = "🚨 СИСТЕМА: ВАС ЗВІЛЬНЕНО!\n\nЧас вийшов. Шеф заблокував вашу перепустку."
		return
		
func _process(delta):
	if chat_display.visible_characters < full_text.length():
		typing_progress += delta

		var percent = typing_progress / typing_time

		chat_display.visible_characters = int(
			full_text.length() * min(percent, 1.0)
		)
	if chat_display.visible_characters >= full_text.length():
		$Sounds/typingSound.stop()
