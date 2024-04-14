extends Control

const CODING_EXTENSION:String = "gsc"
const IMAGE_EXTENSION:String = "iwi"

var selected_game:String = "bo2"
var game_list:Array[String] = ["bo2"] # More will come (I hope.)

var hovered_border_color:Color = Color(0.047, 0, 0.125)

var hovered_tooltip_color:Color = Color(0, 0.682, 1)
var non_hovered_tooltip_color:Color = Color(1, 1, 1)

@onready var panel = $SidePannel/Panel
	
var is_holding_control:bool = false

var is_hovering:bool = false
var hovering_text:String = ""

var info_text:Control

var data:SaveAndLoad = SaveAndLoad.new()

# SAVE
var saved_data:Dictionary = {
	"tooltip": true,
	"fullscreen": false,
	"bo2_path": "",
	"pluto_path": ""
} 

#func _init() -> void:
	#if SaveInfo.game == "" || SaveInfo.game == null: SaveInfo.game = game_list.pick_random()

func set_h_text( node:String ) -> void:
	if (
		!is_holding_control
		&&
		saved_data["tooltip"]
	):
		match node:

			"Add" : hovering_text = "Add/Load a mod to the game.\n([color=orange]" + str(selected_game).to_upper() + "[/color] Is currently selected. Change the game in the [url=quick_options][color=powderblue]SETTINGS[/color][/url])\nVisit [url=quick_help][color=springgreen]HELP[/color][/url] for more infomation."
			"Settings" : hovering_text = "Ajust some settings. And set [color=lime]PATHS[/color] to your game."
			"Source" : hovering_text = "See the [color=gold]SOURCE CODE[/color] on github."
			"Help" : hovering_text = "If your confused on how this app works. Click this.\nThis explains a little about this app too.\nAlso [color=lightblue][url=https://plutonium.pw/]PLUTONIUM[/url][/color] can help."
			
			"Apply" : hovering_text = "Saves all current settings."
			"Discard" : hovering_text = "Does not save all current settings."
			"Tooltip" : hovering_text = "This box your reading this from;\nthis is a tooltip. Tooltips are usefull."
			"Fullscreen" : hovering_text = "Makes the window take up your whole screen.\nBut tere is one error with this.\nThe [color=powderblue]TOOLTIPS[/color] will not change position based\non the position."
			
			"Play" : hovering_text = "Opens the [color=lightblue][url=https://plutonium.pw/]PLUTONIUM[/url][/color] app located in in [url=quick_options][color=powderblue]SETTINGS[/color][/url].\nLOCATION: (" + str(saved_data["pluto_path"]) + ")"

func _input(event:InputEvent) -> void:
	if Input.is_action_pressed("CNTRL"):
		is_holding_control = true
		$InfoText.set("mouse_filter", 0)
	else :
		is_holding_control = false
		$InfoText.set("mouse_filter", 2)

func set_h_pos() -> void:
	if (
		!is_holding_control
		&&
		saved_data["tooltip"]
	):
		var mouse_pos:Vector2 = get_global_mouse_position()
		if mouse_pos.x <= get_viewport().size.x / 2 : $InfoText.position.x = mouse_pos.x + 15
		elif mouse_pos.x >= get_viewport().size.x / 2 : $InfoText.position.x = mouse_pos.x - $InfoText.get_rect().size.x - 5
		
		if saved_data["fullscreen"]:
			var max_words:int = 100
			if $InfoText.text.length() >= max_words: 
				if mouse_pos.y <= DisplayServer.window_get_size().y: $InfoText.position.y = mouse_pos.y - 35
				elif mouse_pos.y >= DisplayServer.window_get_size().y / 2 : $InfoText.position.y = mouse_pos.y - $InfoText.text.length() / 3
			elif $InfoText.text.length() <= max_words:
				if mouse_pos.y <= DisplayServer.window_get_size().y : $InfoText.position.y = mouse_pos.y + 15
				elif mouse_pos.y >= DisplayServer.window_get_size().y / 2 : $InfoText.position.y = mouse_pos.y - 15
		else :
			var max_words:int = 100
			if $InfoText.text.length() >= max_words: 
				if mouse_pos.y <= get_viewport().size.y / 2 : $InfoText.position.y = mouse_pos.y + 15
				elif mouse_pos.y >= get_viewport().size.y / 2 : $InfoText.position.y = mouse_pos.y - $InfoText.text.length() / 3
			elif $InfoText.text.length() <= max_words:
				if mouse_pos.y <= get_viewport().size.y / 2 : $InfoText.position.y = mouse_pos.y + 15
				elif mouse_pos.y >= get_viewport().size.y / 2 : $InfoText.position.y = mouse_pos.y - 15
	
	elif (is_holding_control &&
		saved_data["tooltip"]) : if is_hovering : $InfoText.position = $InfoText.position

func launch_click() -> void:
	if !saved_data["pluto_path"].ends_with("plutonium.exe"):
		OS.alert("Something was wrong with the plutonium path.\nMake sure the plutonium app is called \"plutonium.exe\"\nCURRENT PATH: (" + str(saved_data["pluto_path"] + ")"), "PATH Error")
		return
	OS.shell_open(saved_data["pluto_path"])
	get_tree().quit(0)

func add_click() -> void:
	show_state("Modloader")
	
	if !DirAccess.dir_exists_absolute(saved_data["bo2_path"] + "/T6R/data/images") : DirAccess.make_dir_recursive_absolute(saved_data["bo2_path"] + "/T6R/data/images")
	
	$States/Modloader/Label.text = "Select a folder to move to mods"
	
	$States/Modloader/FileDialog.set("root_subfolder", ("/users/"+str(OS.get_environment("USERNAME"))+"/downloads"))
	$States/Modloader/FileDialog.popup()

func add_directory_selected( dir:String ) -> void:
	#var total_files:int
	#var total_files_start:int
	var iwi:int
	var gsc:int
	#var total_files_together:PackedStringArray = DirAccess.get_files_at(dir+"/")
	#for i in total_files_together:
		#total_files += 1
		#total_files_start += 1
		
	var progress:int = 0
	var is_done:bool = false
	
	var unkown_files:int
	
	for items in (DirAccess.get_files_at(dir+"/")):
		#total_files -= 1
		if items.get_extension() == IMAGE_EXTENSION:
			iwi += 1
			progress += 1
			DirAccess.rename_absolute(dir + "/" + items, saved_data["bo2_path"] + "/T6R/data/images/" + items)
			print("FROM: " + dir + "/" + items)
			print("TO: \n" + saved_data["bo2_path"] + "/T6R/data/images/" + items)
		elif items.get_extension() == CODING_EXTENSION:
			gsc += 1
			progress += 1
		else :
			unkown_files += 1
			progress += 1
	is_done = true
	
	if unkown_files != 0 : $States/Modloader/Label.text = "DONE, " + str(unkown_files) + " file(s) could not be put into mods.\n(These " + str(unkown_files) + " file(s) were not a .iwi or .gsc)"
	else : $States/Modloader/Label.text = "DONE, All good!"
	if progress == 0 : $States/Modloader/Label.text = "No File Detected."

func settings_click() -> void:
	$States/Options/PlutoPath.text = str(saved_data["pluto_path"])
	$States/Options/Bo2Path.text = str(saved_data["bo2_path"])
	
	$States/Options/Tooltip.button_pressed = saved_data["tooltip"]
	$States/Options/Fullscreen.button_pressed = saved_data["fullscreen"]
	show_state("Options")

func source_click() -> void:
	OS.shell_open("https://github.com/Kufferey/plutonium_mod-Plutonium-Manager")

func help_click() -> void:
	show_state("Help")

#func _click() -> void:
	#pass

func apply_click() -> void:
	SaveAndLoad.save_file("plutonium-save-directory.txt", str($States/Options/PlutoPath.text))
	SaveAndLoad.save_file("plutonium-black_ops_2-save-directory.txt", str($States/Options/Bo2Path.text))
	SaveAndLoad.save_file("save-tooltip.txt", str($States/Options/Tooltip.get("button_pressed")))
	SaveAndLoad.save_file("save-fullscreen.txt", str($States/Options/Fullscreen.get("button_pressed")))
	
	if (
		SaveAndLoad.get_saved_file("plutonium-black_ops_2-save-directory.txt")
		&&
		SaveAndLoad.get_saved_file("plutonium-save-directory.txt")
		&&
		SaveAndLoad.get_saved_file("save-fullscreen.txt")
		&&
		SaveAndLoad.get_saved_file("save-tooltip.txt")
	):
		saved_data["bo2_path"] = String(SaveAndLoad.load_file("plutonium-black_ops_2-save-directory.txt"))
		saved_data["pluto_path"] = String(SaveAndLoad.load_file("plutonium-save-directory.txt"))
		saved_data["tooltip"] = bool(str_to_var(SaveAndLoad.load_file("save-tooltip.txt")))
		saved_data["fullscreen"] = bool(str_to_var(SaveAndLoad.load_file("save-fullscreen.txt")))
		
		check_settings()
	
	show_state("Normal")

func discard_click() -> void:
	show_state("Normal")

func help_open_pluto( meta:Variant ) -> void:
	var url = meta
	match url:
		"quick_menu" : show_state("Normal")
		"quick_options" : show_state("Options")
		"quick_add" : show_state("Modloader")
		"quick_help" : show_state("Help")

		"https://plutonium.pw/" : OS.shell_open(url)

func show_state( state:String ) -> void:
	var state_node = $States.get_child_count(true)
	for states in range(state_node):
		
		var node:Node = $States.get_child(states)
		var name_of_node:String = node.name
		
		if name_of_node != state : node.hide()
		elif name_of_node == state : node.show()

func check_settings() -> void:
	if saved_data["fullscreen"] : DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif !saved_data["fullscreen"] : DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	if !saved_data["tooltip"] : $InfoText.hide()
	elif saved_data["tooltip"] : $InfoText.show()
	
	saved_data["bo2_path"] = saved_data["bo2_path"].replace("\\", "/")
	saved_data["pluto_path"] = saved_data["pluto_path"].replace("\\", "/")

func _ready() -> void:
	info_text = $InfoText
	
	var file_path:String = ""
	if !SaveAndLoad.get_dev_mode() : file_path = "res://data/saved/"
	elif SaveAndLoad.get_dev_mode() : file_path = "res://data_dev/"
	
	if (
		bool(SaveAndLoad.get_saved_file("plutonium-black_ops_2-save-directory.txt"))
		&&
		bool(SaveAndLoad.get_saved_file("plutonium-save-directory.txt"))
		&&
		bool(SaveAndLoad.get_saved_file("save-fullscreen.txt"))
		&&
		bool(SaveAndLoad.get_saved_file("save-tooltip.txt"))
	):
		saved_data["bo2_path"] = String(SaveAndLoad.load_file("plutonium-black_ops_2-save-directory.txt"))
		saved_data["pluto_path"] = String(SaveAndLoad.load_file("plutonium-save-directory.txt"))
		saved_data["tooltip"] = bool(str_to_var(SaveAndLoad.load_file("save-tooltip.txt")))
		saved_data["fullscreen"] = bool(str_to_var(SaveAndLoad.load_file("save-fullscreen.txt")))
		
		$States/Options/PlutoPath.text = str(saved_data["pluto_path"])
		$States/Options/Bo2Path.text = str(saved_data["bo2_path"])
		
		$States/Options/Tooltip.button_pressed = saved_data["tooltip"]
		$States/Options/Fullscreen.button_pressed = saved_data["fullscreen"]
	
	check_settings()
	
	show_state("Help")
	
	$SidePannel/Buttons/Play.connect("pressed", launch_click)
	
	$SidePannel/Buttons/Add.connect("pressed", add_click)
	$States/Modloader/FileDialog.connect("dir_selected", add_directory_selected)
	
	$SidePannel/Buttons/Settings.connect("pressed", settings_click)
	$SidePannel/Buttons/Source.connect("pressed", source_click)
	$SidePannel/Buttons/Help.connect("pressed", help_click)
	
	$States/Options/Apply.connect("pressed", apply_click)
	$States/Options/Discard.connect("pressed", discard_click)
	
	$States/Help/about.connect("meta_clicked", help_open_pluto)
	$InfoText.connect("meta_clicked", help_open_pluto)
	
	for i in $SidePannel/Buttons.get_children(true):
		i.connect("mouse_entered", func():
			is_hovering = true
			var the_node = i.name
			set_h_text( the_node )
		)
		
		i.connect("mouse_exited", func():
			is_hovering = false
			if !is_holding_control : hovering_text = ""
			)
			
	for i in $States/Options.get_children(true):
		if i is Button || i is CheckBox:
			i.connect("mouse_entered", func():
				is_hovering = true
				var the_node = i.name
				set_h_text( the_node )
			)
			
			i.connect("mouse_exited", func():
				is_hovering = false
				if !is_holding_control : hovering_text = ""
				)

func check_for_tooltip_hover() -> void:
	var tooltip:RichTextLabel = $InfoText

func _process(delta) -> void:
	$InfoText.text = hovering_text
	if saved_data["tooltip"]:
		if (
			is_hovering
			&& !is_holding_control
		):
			set_h_pos()
			$InfoText.show()
		elif (
			!is_hovering
			&& !is_holding_control
		):
			$InfoText.hide()
		elif (
			!is_hovering
			&& is_holding_control
		):
			$InfoText.position = $InfoText.position
		
		if !hovering_text.contains("\n") : $InfoText.set("size", Vector2(118, 23))
	
	if (
		is_holding_control
		&&
		$InfoText.get("mouse_entered")
		&&
		Input.is_action_pressed("LCLICK")
		&&
		is_hovering
	):
		h_lock = true
		$InfoText.position = get_global_mouse_position() - Vector2(($InfoText.get_rect().size.x / 2),
		0)
	else :
		h_lock = false
	
	check_for_tooltip_hover()

var h_lock:bool = false
func _on_info_text_mouse_entered():
	if ! h_lock:
		is_hovering = true
		$InfoText.modulate = hovered_tooltip_color

func _on_info_text_mouse_exited():
	if ! h_lock:
		is_hovering = false
		$InfoText.modulate = non_hovered_tooltip_color
