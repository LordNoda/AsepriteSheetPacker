extends Node2D

@onready var exe_selector : FileDialog = $exe_selector
@onready var sprite_file_selector : FileDialog  = $sprite_file_selector
@onready var output_directory_selector : FileDialog  = $output_directory_selector
@onready var item_list : ItemList = $Control/ItemList
@onready var aseprite_location : TextEdit = $Control/AsepriteLocation
@onready var output_location : TextEdit = $Control/outputpath
@onready var filename : TextEdit = $Control/Filename

var _selected_item : int

# Called when the node enters the scene tree for the first time.
func _ready():
	item_list.item_selected.connect(item_selected)
	exe_selector.file_selected.connect(exe_selected)
	sprite_file_selector.files_selected.connect(sprites_selected)
	output_directory_selector.dir_selected.connect(output_selected)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# FIND EXE
func exe_selected(path : String) -> void:
	aseprite_location.text = path
	pass

func _on_asprite_button_pressed():
	exe_selector.access = exe_selector.ACCESS_FILESYSTEM
	exe_selector.file_mode = exe_selector.FILE_MODE_OPEN_FILE 
	exe_selector.visible = true
	pass # Replace with function body.

# FIND SPRITE
func sprites_selected(paths : PackedStringArray) -> void:
	if paths.size() > 0:
		for path in paths:
			item_list.add_item(path)
	pass

func _on_sprite_button_pressed():
	sprite_file_selector.access = sprite_file_selector.ACCESS_FILESYSTEM
	sprite_file_selector.file_mode = sprite_file_selector.FILE_MODE_OPEN_FILES 
	sprite_file_selector.visible = true
	pass # Replace with function body.

# FIND OUTPUT DIRECTORY
func output_selected(path : String) -> void:
	output_location.text = path
	pass

func _on_output_path_button_pressed():
	output_directory_selector.access = output_directory_selector.ACCESS_FILESYSTEM
	output_directory_selector.file_mode = output_directory_selector.FILE_MODE_OPEN_DIR 
	output_directory_selector.visible = true
	pass # Replace with function body.
	
	
# SORT LIST
func item_selected(index : int) -> void:
	_selected_item = index
	pass
	
func _on_up_pressed():
	if _selected_item < 0:
		return
	var _new_id = _selected_item - 1
	if _new_id < 0:
		_new_id = 0
	item_list.move_item( _selected_item, _new_id)
	_selected_item = _new_id
	pass # Replace with function body.
	
func _on_down_pressed():
	if _selected_item < 0:
		return
	var _new_id = _selected_item + 1
	item_list.move_item( _selected_item, _new_id)
	_selected_item = _new_id
	pass # Replace with function body.
	
func _on_delete_pressed():
	if _selected_item < 0:
		return
	item_list.remove_item( _selected_item)
	# Reset Selection
	item_list.deselect_all()
	_selected_item = -1
	pass # Replace with function body.


func _on_generate_button_pressed():
	# Get all sprite sheet names in ordered list
	var sprites : String = ""
	
	# Create .Bat file
	var bat_file = FileAccess.open("user://spritepack.bat", FileAccess.WRITE)
	#bat_file.flush()
	#bat_file.store_line(str("xcopy /f /y \"", item_list.get_item_text(1), "*\" \"", aseprite_location.text,"\\",str(1),".aseprite*\""))
	#bat_file.close()
	
	for index in item_list.item_count:
		sprites += str(_quote_text(item_list.get_item_text(index)), " ")
		
	bat_file.flush()
	bat_file.store_line(str(
		aseprite_location.text, " ",
		"--batch ",
		sprites, " ",
		"--sheet ",
		str(output_location.text, "\\", filename.text, ".png"), " ",
		"-sheet-pack" 	
	))
	bat_file.close()
	
	var output = []
	OS.execute("CMD.exe", ["/c", ProjectSettings.globalize_path("user://spritepack.bat")], output, true, true)
	print(output)
	pass # Replace with function body.
	
func _quote_text( text : String ) -> String:
	return str("\"", text, "\"") 
