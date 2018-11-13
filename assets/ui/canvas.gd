extends CanvasLayer

onready var textBox = $container/textBox
onready var textLabel = $container/textBox/text

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

# resetText
# Clears the label and hides the text box
func resetText():
	textBox.hide()
	textLabel.text = ""

# setText
# Shows the text box and updates its content
func setText(text):
	textBox.show()
	textLabel.text = text

# Signals

func _on_textTimer_timeout():
	if textLabel.visible_characters != textLabel.get_total_character_count():
		textLabel.visible_characters += 1
