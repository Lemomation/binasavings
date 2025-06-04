extends Control

@onready var line_edit: LineEdit = $LineEdit
@onready var button: Button = $Button
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var const_options: OptionButton = $ConstOptions
@onready var refoptions: OptionButton = $refoptions
@onready var progr_ess_label: RichTextLabel = $"ProgressBar/PROGREss label"
@onready var progr_ess_label_2: RichTextLabel = $"ProgressBar/PROGREss label2"
@onready var fatesenter: LineEdit = $Fatesenter
@onready var totalprimosrtl: RichTextLabel = $Totalprimosrtl

const SAVE_PATH := "user://preferences.json"

var constellation_goals: Dictionary = {
	"C0": 14400,
	"C1": 28800,
	"C2": 43200,
	"C3": 57600,
	"C4": 72000,
	"C5": 86000,
	"C6": 100800
}

var weapon_costs: Dictionary = {
	"No Weapon": 0,
	"R1": 12800,
	"R2": 25600,
	"R3": 38400,
	"R4": 51200,
	"R5": 64000
}

var GOAL_PRIMOS: int = 155200

func _ready() -> void:
	# Connect UI signals
	const_options.item_selected.connect(_on_selection_changed)
	refoptions.item_selected.connect(_on_selection_changed)
	button.pressed.connect(_on_button_pressed)

	# Load saved preferences if available
	_load_preferences()

	_update_total_goal()

func _on_selection_changed(index: int) -> void:
	_update_total_goal()

func _on_button_pressed() -> void:
	_update_progress()
	_save_preferences()

func _update_total_goal() -> void:
	var char_key: String = const_options.get_item_text(const_options.selected)
	var weap_key: String = refoptions.get_item_text(refoptions.selected)

	var char_primos: int = constellation_goals.get(char_key, 0)
	var weap_primos: int = weapon_costs.get(weap_key, 0)

	GOAL_PRIMOS = char_primos + weap_primos
	progress_bar.max_value = GOAL_PRIMOS
	_update_progress()

func _update_progress() -> void:
	var current_primos := int(line_edit.text)
	var current_fates := int(fatesenter.text)
	var current_total_primos := current_fates*160 + current_primos
	
	progress_bar.value = clamp(current_total_primos, 0, GOAL_PRIMOS)
	print("Current primos:", current_primos, "/", GOAL_PRIMOS)
	progr_ess_label.text = str(current_total_primos)
	progr_ess_label_2.text = str(GOAL_PRIMOS)
	totalprimosrtl.text = str(current_total_primos)
func _save_preferences() -> void:
	var data := {
		"current_primos": line_edit.text,
		"const_index": const_options.selected,
		"weapon_index": refoptions.selected
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func _load_preferences() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()

	var result : Variant = JSON.parse_string(content)
	if result is Dictionary:
		# Restore saved data
		line_edit.text = str(result.get("current_primos", "0"))
		const_options.select(result.get("const_index", 0))
		refoptions.select(result.get("weapon_index", 0))
