extends Node

const SaveDir := "user/"
const SaveName :="Save.json"

func _ready():
	print("SaveManager is active")

# Lets plan out the actual save file
# One: areas restored
# Last position
# restoration energy left
# Portals done

func create_save() -> SaveData:
	var savedata := SaveData.new()
	savedata.restoration_energy = 0
	savedata.portals_beaten = 0
	savedata.areas_restored = []
	savedata.last_position = Vector2(80, 380)
	ResourceSaver.save(savedata, "user://save.tres")
	return savedata

func load_save() -> SaveData:
	if ResourceLoader.exists("user://save.tres"):
		return ResourceLoader.load("user://save.tres", "", ResourceLoader.CACHE_MODE_IGNORE) as SaveData
	return create_save()


func update_save(save: SaveData) -> void:
	ResourceSaver.save(save, "user://save.tres")
