extends Node

# Главные переменные нашей "нейросети"
var player_money: float = 0.0       # Баланс заработанных денег
var player_penalties: int = 0       # Количество штрафов от сурового шефа
var current_question_index: int = 0 # Какой по счету вопрос сейчас активен
var is_game_over: bool = false      # Проиграл ли игрок (уволен ли)
