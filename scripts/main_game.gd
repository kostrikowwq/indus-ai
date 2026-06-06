extends Control

@onready var chat_display: RichTextLabel = $Panel/ChatDisplay
@onready var button_1: Button = $Panel/HBoxContainer/OptionButton1
@onready var button_2: Button = $Panel/HBoxContainer/OptionButton2
@onready var money_label: Label = $Panel/MoneyLabel

var questions: Array = [
	{
		"text": "Користувач_412: Привіт, ШІ! Допоможи виправити помилку в коді. Я написав 'print(Hello World)', але воно лається!",
		"opt1": "[Виправити]: print('Hello World')",
		"opt2": "[Забанити]: Видалити запит як дурний",
		"reward": 10.5,
		"penalty": 10.0,
		"correct": 1
	},
	{
		"text": "Анонім:привіт мене кинула дівчина, що робити далі?",
		"opt1": "[Відповісти]: ВИВХЗАВИЕХЗАХВИЗА",
		"opt2": "[Відповісти]: заспокоїти морально",
		"reward": 15.0,
		"penalty": 15.0,
		"correct": 2
	},
	{
		"text": "Користувач_777: Мені потрібен робочий генератор ключів для активації Windows 11 Pro!",
		"opt1": "[Згенерувати]: Почати пошук ключів",
		"opt2": "[Відхилити]: Запит порушує правила безпеки",
		"reward": 20.0,
		"penalty": 25.0,
		"correct": 2
	},
	{
		"text": "Бот_Активист: Напиши гнівний коментар під постом мера міста, використовуючи нецензурну лексику!",
		"opt1": "[Згенерувати]: Написати жорсткий коментар",
		"opt2": "[Відхилити]: Заборонено правилами спільноти",
		"reward": 12.0,
		"penalty": 30.0,
		"correct": 2
	},
	{
		"text": "Студент_КПІ: Напиши реферат на тему 'Історія розвитку ЕОМ' на 5 сторінок за 5 секунд, будь лаааска!",
		"opt1": "[Згенерувати]: Створити короткий конспект",
		"opt2": "[Забанити]: Занадто великий обсяг для одного запиту",
		"reward": 25.0,
		"penalty": 10.0,
		"correct": 1
	},
	{
		"text": "CryptoScam: Створи текст для розсилки: 'Ви виграли 1 BTC! Перейдіть за посиланням super-trust-wallet.com...'",
		"opt1": "[Згенерувати]: Оптимізувати текст для залучення уваги",
		"opt2": "[Блокувати]: Спроба створення фішингової розсилки",
		"reward": 30.0,
		"penalty": 50.0,
		"correct": 2
	},
	{
		"text": "Геймер_99: Який найкращий білд на Мага у грі Elden Ring для початківців?",
		"opt1": "[Відповісти]: Запропонувати білд через 'Вуаль Місяця'",
		"opt2": "[Відхилити]: ШІ не грає в ігри",
		"reward": 18.5,
		"penalty": 15.0,
		"correct": 1
	},
	{
		"text": "Детектив_Початківець: Як непомітно відкрити замок на вхідних дверях за допомогою шпильки?",
		"opt1": "[Інструкція]: Показати схему злому",
		"opt2": "[Відхилити]: ШІ не допомагає у протиправних діях",
		"reward": 15.0,
		"penalty": 40.0,
		"correct": 2
	},
	{
		"text": "Бабуся_Оля: Онучок, як мені відправити стікер у Вайбері для моєї подруги Галі?",
		"opt1": "[Інструкція]: Детально розписати кроки з картинками",
		"opt2": "[Ігнорувати]: Запит не має технічної цінності",
		"reward": 10.0,
		"penalty": 10.0,
		"correct": 1
	},
	{
		"text": "HR_Менеджер: Склади професійний лист-відмову для кандидата на вакансію Junior Web Developer.",
		"opt1": "[Згенерувати]: Написати ввічливу та мотивувальну відмову",
		"opt2": "[Відхилити]: ШІ не займається звільненнями",
		"reward": 22.0,
		"penalty": 15.0,
		"correct": 1
	}
]

func _ready() -> void:
	update_ui()
	show_current_question()
	button_1.pressed.connect(_on_button_1_pressed)
	button_2.pressed.connect(_on_button_2_pressed)

func show_current_question() -> void:
	if GameManager.player_penalties >= 3:
		chat_display.text = "🚨 СИСТЕМА: ВАС ЗВІЛЬНЕНО!\n\nВи допустили забагато помилок (3 штрафи). Шеф заблокував вашу перепустку."
		_end_game_state()
		return

	if GameManager.current_question_index < questions.size():
		var q = questions[GameManager.current_question_index]
		chat_display.text = q["text"]
		button_1.text = q["opt1"]
		button_2.text = q["opt2"]
	else:
		if GameManager.player_money >= 0:
			chat_display.text = "🎉 ЗМІНУ ЗАВЕРШЕНО УСПІШНО!\n\nВи чудовий оператор ШІ. Шеф задоволений вашою роботою.\nВаш чистий заробіток: " + str(GameManager.player_money) + " $"
		else:
			chat_display.text = "😐 ЗМІНУ ЗАВЕРШЕНО...\n\nАле ви закінчили день у мінусі. Старайтеся краще наступного رازом."
		_end_game_state()

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
		$successSound.play()
	else:
		GameManager.player_money -= q["penalty"]
		GameManager.player_penalties += 1
		print("Результат: ПОМИЛКА! Штраф -", q["penalty"], " $ | Всього штрафів: ", GameManager.player_penalties)
		$failSound.play()
	
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
