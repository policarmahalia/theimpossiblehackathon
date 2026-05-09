# eyenstein_helper.gd
extends Node2D

# --- API SETUP ---
var API_KEY: String = ""
var API_URL: String = "https://api.groq.com/openai/v1/chat/completions"

# --- RATE LIMITING ---
var retry_until: float = 0.0
var COOLDOWN_SECONDS: float = 5.0

# --- NODE REFERENCES ---
@onready var eyenstein_area = $EyensteinArea
@onready var eyenstein_sprite = $EyensteinArea/AnimatedSprite2D
@onready var notif_bubble = $NotifBubble
@onready var http_request = $HTTPRequest
@onready var chat_panel = $ChatPanel
@onready var eyenstein_big = $ChatPanel/PanelContainer/VBoxContainer/EyensteinBig
@onready var response_label = $ChatPanel/ResponseLabel
@onready var input_field = $ChatPanel/InputField
@onready var send_button = $ChatPanel/SendButton
@onready var close_button = $ChatPanel/CloseButton
@onready var loading_label = $ChatPanel/LoadingLabel

func _ready():
	API_KEY = _load_api_key()
	chat_panel.visible = false
	loading_label.visible = false
	eyenstein_sprite.play("float") 
	eyenstein_area.input_event.connect(_on_eyenstein_clicked)
	send_button.pressed.connect(_on_send_pressed)
	close_button.pressed.connect(_on_close_pressed)
	http_request.request_completed.connect(_on_request_completed)
	input_field.text_submitted.connect(_on_input_submitted)

func _load_api_key() -> String:
	var config = ConfigFile.new()
	var err = config.load("res://api_config.cfg")
	if err == OK:
		return config.get_value("keys", "gemini_api_key", "")
	push_error("api_config.cfg not found!")
	return ""

func _on_eyenstein_clicked(_viewport, event, _shape):
	if event is InputEventMouseButton and event.pressed:
		_open_chat()

func _open_chat():
	chat_panel.visible = true
	notif_bubble.visible = false
	input_field.grab_focus()
	response_label.text = "what can i do for you?"

func _on_close_pressed():
	chat_panel.visible = false
	notif_bubble.visible = true
	input_field.text = ""
	response_label.text = ""

func _on_input_submitted(text):
	_send_to_groq(text)

func _on_send_pressed():
	_send_to_groq(input_field.text)

func _send_to_groq(user_text: String):
	if user_text.strip_edges() == "":
		return

	var now = Time.get_ticks_msec() / 1000.0
	if now < retry_until:
		var wait = ceil(retry_until - now)
		response_label.text = "hold on. ask me again in %ds." % wait
		return

	retry_until = now + COOLDOWN_SECONDS

	send_button.disabled = true
	input_field.editable = false
	loading_label.visible = true
	loading_label.text = "thinking..."
	response_label.text = ""

	var body = JSON.stringify({
		"model": "llama-3.1-8b-instant",
		"messages": [{"role": "user", "content": user_text}],
		"max_tokens": 200
	})
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + API_KEY
	]
	var error = http_request.request(API_URL, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		response_label.text = "ugh something broke. try again."
		retry_until = 0.0
		_reset_input()

func _on_request_completed(result, response_code, _headers, body):
	_reset_input()

	if result != HTTPRequest.RESULT_SUCCESS:
		response_label.text = "network's down or something. not my problem."
		return

	var json = JSON.new()
	var raw = body.get_string_from_utf8()
	if json.parse(raw) != OK:
		response_label.text = "i said something but even i don't know what."
		return

	var data = json.get_data()

	if response_code == 429:
		var retry_secs = _parse_retry_delay(data)
		retry_until = Time.get_ticks_msec() / 1000.0 + retry_secs
		response_label.text = "i'm exhausted. ask me again in %ds." % retry_secs
		return

	if response_code != 200:
		response_label.text = "i can't talk right now. figure it out yourself."
		return

	var response_text = data["choices"][0]["message"]["content"]
	response_label.text = response_text
	input_field.text = ""

func _parse_retry_delay(data: Dictionary) -> int:
	var retry_after = data.get("error", {}).get("message", "")
	if retry_after.contains("Please try again in"):
		var parts = retry_after.split("in ")
		if parts.size() > 1:
			return int(parts[1].split("s")[0].strip_edges())
	return 30

func _reset_input():
	send_button.disabled = false
	input_field.editable = true
	loading_label.visible = false
	input_field.grab_focus()

func update_sprite(irritation_level: int):
	match irritation_level:
		0: eyenstein_sprite.play("float")
		1: eyenstein_sprite.play("confused")
		2: eyenstein_sprite.play("irritated")
		3: eyenstein_sprite.play("angry")
