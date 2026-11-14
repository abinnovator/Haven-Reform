const SaveDir := "user/"
const SaveName :="Save.json"

func _ready():
	print("SaveManager is active")

# Lets plan out the actual save file
# One: areas restored
# Last position
# restoration energy left
# Portals done


func create_save():
	var savedata: SaveData = SaveData.new()
	# Ok so first we have to access or create the file
	savedata.restoration_energy = 0
	savedata.portals_beaten = 0
	savedata.areas_restored = []
	savedata.last_position = []

	ResourceSaver.save(savedata, "user://save.tres")

func load_save():
	if ResourceLoader.exists("user://save.tres"):
		return ResourceLoader.load("user://save.tres", "",  ResourceLoader.CACHE_MODE_IGNORE) as SaveData
func update_save(save: SaveData):
	if ResourceLoader.exists("user://save.tres"):
		ResourceSaver.save(save, "user://save.tres")
