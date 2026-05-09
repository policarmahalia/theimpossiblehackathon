# eyenstein_helper.gd
extends Node2D

# --- API SETUP ---
var GEMINI_API_KEY: String = ""
var GEMINI_URL: String = ""

const SYSTEM_PROMPT = """
You are Eyenstein, a sarcastic but helpful AI eye entity 
in a game called Bun Bun's Tale. You are helping a 
dumb bunny called BunBun figure out what to eat. 
Keep responses short, 2-3 sentences max. 
Be a little condescending but still give the right answer.
The bunny needs to eat a carrot right now.
"""

# --- NODE REFERENCES ---
@onready var eyenstein_area = $EyensteinArea
@onready var eyenstein_sprite = $EyensteinArea/AnimatedSprite2D
@onready var notif_bubble = $NotifBubble
@onready var http_request = $HTTPRequest
@onready var chat_panel = $ChatPanel
@onready var eyenstein_big = $ChatPanel/PanelContainer/VBoxContainer/EyensteinBig
@onready var response_label = $ChatPanel/PanelContainer/VBoxContainer/ResponseLabel
@onready var input_field = $ChatPanel/PanelContainer/VBoxContainer/InputField
@onready var send_button = $ChatPanel/PanelContainer/VBoxContainer/SendButton
@onready var close_button = $ChatPanel/PanelContainer/VBoxContainer/CloseButton
@onready var loading_label = $ChatPanel/LoadingLabel


func _ready():
	# load key first
	GEMINI_API_KEY = _load_api_key()
	GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=" + GEMINI_API_KEY

	chat_panel.visible = false
	loading_label.visible = false

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
	_send_to_gemini(text)


func _on_send_pressed():
	_send_to_gemini(input_field.text)


func _send_to_gemini(user_text: String):
	if user_text.strip_edges() == "":
		return

	send_button.disabled = true
	input_field.editable = false
	loading_label.visible = true
	loading_label.text = "thinking..."
	response_label.text = ""

	var body = JSON.stringify({
		"system_instruction": {
			"parts": [{"text": SYSTEM_PROMPT}]
		},
		"contents": [
			{
				"parts": [{"text": user_text}]
			}
		]
	})

	var headers = ["Content-Type: application/json"]
	var error = http_request.request(GEMINI_URL, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		response_label.text = "ugh something broke. try again."
		_reset_input()


func _on_request_completed(result, response_code, _headers, body):
	_reset_input()

	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		response_label.text = "i can't talk right now. figure it out yourself."
		return

	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())

	if parse_result != OK:
		response_label.text = "i said something but even i don't know what."
		return

	var data = json.get_data()
	var response_text = data["candidates"][0]["content"]["parts"][0]["text"]
	response_label.text = response_text
	input_field.text = ""


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
