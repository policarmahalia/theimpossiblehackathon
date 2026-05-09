extends Node

# ─────────────────────────────────────────
#  NODE REFERENCES
# ─────────────────────────────────────────

@onready var puzzle_panel     = $PuzzlePanel
@onready var question_label   = $PuzzlePanel/QuestionLabel
@onready var feedback_label   = $PuzzlePanel/FeedbackLabel
@onready var explain_label    = $PuzzlePanel/ExplainLabel

@onready var option1          = $PuzzlePanel/OptionsGrid/Option1
@onready var option2          = $PuzzlePanel/OptionsGrid/Option2
@onready var option3          = $PuzzlePanel/OptionsGrid/Option3
@onready var option4          = $PuzzlePanel/OptionsGrid/Option4

@onready var hp_fill          = $HPBar/Fill
@onready var irr_pip1         = $IrritationPips/Pip1
@onready var irr_pip2         = $IrritationPips/Pip2
@onready var irr_pip3         = $IrritationPips/Pip3

@onready var eyenstein_sprite = $EyensteinHelper/EyensteinSprite
@onready var notif_bubble     = $EyensteinHelper/NotifBubble
@onready var chat_panel       = $EyensteinHelper/ChatPanel
@onready var input_field      = $EyensteinHelper/ChatPanel/InputField
@onready var send_button      = $EyensteinHelper/ChatPanel/SendButton


# ─────────────────────────────────────────
#  QUESTION DATA  (just Q1)
# ─────────────────────────────────────────

const QUESTION = "Click the smallest thing on this page."
const OPTIONS  = ["A) The moon", "B) An atom", "C) This full stop.", "D) A grain of sand"]
const ANSWER   = 2   # index of correct option (C)
const EXPLAIN  = "It's literally the smallest visible thing on the page."


# ─────────────────────────────────────────
#  CONSTANTS
# ─────────────────────────────────────────

const MAX_IRRITATION := 3
const HP_REWARD      := 30     # HP restored on correct answer
const HP_BAR_WIDTH   := 90.0   # must match your HPBar/Fill node's max width in px


# ─────────────────────────────────────────
#  STATE
# ─────────────────────────────────────────

var answered          : bool   = false
var _gemini_context   : String = ""

const GEMINI_API_KEY = "YOUR_GEMINI_API_KEY_HERE"
const GEMINI_URL     = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=" + GEMINI_API_KEY
var http_request     : HTTPRequest
var is_waiting_for_ai: bool = false


# ─────────────────────────────────────────
#  READY
# ─────────────────────────────────────────

func _ready():
	chat_panel.visible  = false
	explain_label.text  = ""
	feedback_label.text = ""

	# Set question text
	question_label.text = QUESTION
	option1.text = OPTIONS[0]
	option2.text = OPTIONS[1]
	option3.text = OPTIONS[2]
	option4.text = OPTIONS[3]

	# HTTP node for Gemini
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_gemini_response)

	# Connect buttons
	option1.pressed.connect(_on_option_pressed.bind(0))
	option2.pressed.connect(_on_option_pressed.bind(1))
	option3.pressed.connect(_on_option_pressed.bind(2))
	option4.pressed.connect(_on_option_pressed.bind(3))

	# Connect Eyenstein
	eyenstein_sprite.gui_input.connect(_on_eyenstein_clicked)
	send_button.pressed.connect(_on_send_button_pressed)
	input_field.text_submitted.connect(_on_input_submitted)

	# Set Gemini context for this question
	_gemini_context = """You are Eyenstein, a cheeky AI eye character in a kids' puzzle game called 'Bun Bun the Dum Dum'.
The current question is: '%s'
The options are: %s
Give a short, playful hint WITHOUT directly saying the answer. Max 2 sentences. Be sassy but kind.""" \
	% [QUESTION, ", ".join(OPTIONS)]

	_update_hp_bar()
	_update_irritation_ui()
	_update_eyenstein_sprite()


# ─────────────────────────────────────────
#  ANSWER LOGIC
# ─────────────────────────────────────────

func _on_option_pressed(idx: int):
	if answered:
		return
	answered = true
	_set_options_disabled(true)
	explain_label.text = EXPLAIN

	if idx == ANSWER:
		_handle_correct(idx)
	else:
		_handle_wrong(idx)


func _handle_correct(idx: int):
	_tint_option(idx, Color("#7dcf4a"), Color("#4a8c2a"))

	feedback_label.text     = "CORRECT! BunBun can eat the carrot!"
	feedback_label.modulate = Color("#7dcf4a")
	notif_bubble.text       = "NICE ONE!"

	GameManager.restore_health(HP_REWARD)
	_update_hp_bar()

	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://MainWorld.tscn")


func _handle_wrong(wrong_idx: int):
	_tint_option(wrong_idx, Color("#ff6666"), Color("#aa2222"))
	_tint_option(ANSWER,    Color("#7dcf4a"), Color("#4a8c2a"))

	feedback_label.text     = "WRONG! Try again next time..."
	feedback_label.modulate = Color("#ff6666")

	GameManager.irritation_level = min(GameManager.irritation_level + 1, MAX_IRRITATION)
	_update_irritation_ui()
	_update_eyenstein_sprite()

	if GameManager.irritation_level >= MAX_IRRITATION:
		feedback_label.text = "EYENSTEIN IS FURIOUS!"
		await get_tree().create_timer(1.8).timeout
		get_tree().change_scene_to_file("res://BossFight.tscn")
		return

	if GameManager.irritation_level == 2:
		_show_warning_flash()


# ─────────────────────────────────────────
#  OPTION BUTTON STYLING
# ─────────────────────────────────────────

func _tint_option(idx: int, font_col: Color, border_col: Color):
	var btns = [option1, option2, option3, option4]
	var btn  = btns[idx]
	btn.add_theme_color_override("font_color", font_col)
	var style: StyleBoxFlat = btn.get_theme_stylebox("normal").duplicate()
	style.border_color = border_col
	style.bg_color     = Color(border_col, 0.15)
	for state in ["normal", "hover", "pressed", "disabled"]:
		btn.add_theme_stylebox_override(state, style)


func _set_options_disabled(val: bool):
	option1.disabled = val
	option2.disabled = val
	option3.disabled = val
	option4.disabled = val


# ─────────────────────────────────────────
#  HP BAR
# ─────────────────────────────────────────

func _update_hp_bar():
	hp_fill.size.x = HP_BAR_WIDTH * clampf(float(GameManager.health) / 100.0, 0.0, 1.0)


# ─────────────────────────────────────────
#  IRRITATION PIPS & EYENSTEIN
# ─────────────────────────────────────────

func _update_irritation_ui():
	var on  = Color("#ef9f27")
	var off = Color("#1a1a3e")
	irr_pip1.modulate = on if GameManager.irritation_level >= 1 else off
	irr_pip2.modulate = on if GameManager.irritation_level >= 2 else off
	irr_pip3.modulate = on if GameManager.irritation_level >= 3 else off


func _update_eyenstein_sprite():
	match GameManager.irritation_level:
		0:
			eyenstein_sprite.texture = load("res://assets/eyenstein/eye_happy.png")
			notif_bubble.text        = "Need a hint?"
		1:
			eyenstein_sprite.texture = load("res://assets/eyenstein/eye_annoyed.png")
			notif_bubble.text        = "Get it right..."
		2:
			eyenstein_sprite.texture = load("res://assets/eyenstein/eye_angry.png")
			notif_bubble.text        = "Last chance!!"
		3:
			eyenstein_sprite.texture = load("res://assets/eyenstein/eye_rage.png")
			notif_bubble.text        = "THAT'S IT!!"


# ─────────────────────────────────────────
#  WARNING FLASH (irritation == 2)
# ─────────────────────────────────────────

func _show_warning_flash():
	feedback_label.text     = "Prompt better — let me help you!"
	feedback_label.modulate = Color.ORANGE
	var tween = create_tween().set_loops(3)
	tween.tween_property(eyenstein_sprite, "scale", Vector2(1.3, 1.3), 0.15)
	tween.tween_property(eyenstein_sprite, "scale", Vector2(1.0, 1.0), 0.15)


# ─────────────────────────────────────────
#  EYENSTEIN CHAT (GEMINI)
# ─────────────────────────────────────────

func _on_eyenstein_clicked(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		chat_panel.visible   = !chat_panel.visible
		notif_bubble.visible = !chat_panel.visible
		if chat_panel.visible:
			input_field.grab_focus()


func _on_send_button_pressed():
	_send_to_gemini(input_field.text)


func _on_input_submitted(text: String):
	_send_to_gemini(text)


func _send_to_gemini(user_text: String):
	if user_text.strip_edges() == "" or is_waiting_for_ai:
		return
	is_waiting_for_ai    = true
	send_button.disabled = true
	notif_bubble.text    = "Thinking..."

	var body = JSON.stringify({
		"contents": [{"parts": [{"text": _gemini_context + "\n\nPlayer asks: " + user_text}]}]
	})
	http_request.request(GEMINI_URL, ["Content-Type: application/json"], HTTPClient.METHOD_POST, body)
	input_field.text = ""


func _on_gemini_response(_result, response_code, _headers, body):
	is_waiting_for_ai    = false
	send_button.disabled = false

	if response_code != 200:
		notif_bubble.text = "AI is napping... try again!"
		return

	var json = JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		notif_bubble.text = "Couldn't understand the AI!"
		return

	notif_bubble.text    = json.get_data()["candidates"][0]["content"]["parts"][0]["text"]
	notif_bubble.visible = true
