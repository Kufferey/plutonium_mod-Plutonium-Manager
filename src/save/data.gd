class_name SaveAndLoad extends Resource

const DEV_MODE:bool = true # For exporting to release.

static func save_file( path:String , contents:String ) -> void:
	if !DEV_MODE:
		var file:FileAccess = FileAccess.open("res://data/saved/"+path, FileAccess.WRITE)
		file.store_string(contents)
		file.close()
	else :
		var file:FileAccess = FileAccess.open("res://data_dev/"+path, FileAccess.WRITE)
		file.store_string(contents)
		file.close()

static func load_file( path:String ) -> String:
	if !DEV_MODE:
		var file:FileAccess = FileAccess.open("res://data/saved/"+path, FileAccess.READ)
		var text:String = file.get_as_text(false)
		file.close()
		return text
	else :
		var file:FileAccess = FileAccess.open("res://data_dev/"+path, FileAccess.READ)
		file.get_as_text(false)
		var text:String = file.get_as_text(false)
		file.close()
		return text

static func get_saved_file( path:String ) -> bool:
	if (
		!DEV_MODE
		&& FileAccess.file_exists("res://data/saved/"+path)
	):
		return true
	elif (
		DEV_MODE
		&& FileAccess.file_exists("res://data_dev/"+path)
	):
		return true
	return false

static func get_dev_mode() -> bool:
	return DEV_MODE
