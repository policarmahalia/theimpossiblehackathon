extends Node2D

# Get references to your nodes - adjust paths to match your scene tree
@onready var sprite1 = $AnimatedSprite2D
@onready var sprite2 = $AnimatedSprite2D2
@onready var button1 = $Button        # adjust if you have 2 separate buttons
@onready var button2 = $Button2       # adjust node name as needed
@onready var text_label = $Label      # adjust node name as needed

func _ready() -> void:
	# 1. Play idle on both sprites immediately
	sprite1.play("idle")
	sprite2.play("idle")
	
	# 2. Hide text + buttons initially
	text_label.hide()
	button1.hide()
	button2.hide()
	
	# 3. Show them after a short delay (or immediately — your choice)
	await get_tree().create_timer(1.0).timeout
	text_label.show()
	button1.show()
	button2.show()
	
	# 4. Connect button signals
	button1.pressed.connect(_on_button1_pressed)
	button2.pressed.connect(_on_button2_pressed)

func _on_button1_pressed() -> void:
	# Whatever button 1 does
	pass

func _on_button2_pressed() -> void:
	# Change sprite2 to walk animation
	sprite2.play("walk")

func _process(_delta: float) -> void:
	pass
