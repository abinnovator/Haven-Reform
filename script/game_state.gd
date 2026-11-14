extends Node
## Live run state for HAVEN - REFORM. Survives scene changes; the only
## thing that knows how much restoration substance exists.

signal substance_changed()

## Substance you are carrying right now. Lost (partly) if a monster hits you.
var carried_substance := 0
## Substance safely banked in HAVEN-REFORM, spent on restoring patches.
var banked_substance := 0
var portals_beaten := 0
var restored_patches: Array[String] = []


func _ready() -> void:
	var save: SaveData = Savemanager.load_save()
	if save == null:
		return
	banked_substance = save.restoration_energy
	portals_beaten = save.portals_beaten
	restored_patches.assign(save.areas_restored)


## Mirror the banked total into the save file.
func persist() -> void:
	var save: SaveData = Savemanager.load_save()
	if save == null:
		return
	save.restoration_energy = banked_substance
	save.portals_beaten = portals_beaten
	save.areas_restored = restored_patches
	Savemanager.update_save(save)


func add_carried(amount: int) -> void:
	carried_substance += amount
	substance_changed.emit()


## Called when you step back through the return portal: carried becomes banked.
func bank_run() -> int:
	var banked := carried_substance
	banked_substance += carried_substance
	carried_substance = 0
	portals_beaten += 1
	persist()
	substance_changed.emit()
	return banked


## Knocked down: drop some of what you are carrying, never what is banked.
func drop_carried(fraction := 0.34) -> int:
	var lost := int(ceil(carried_substance * fraction))
	carried_substance = maxi(0, carried_substance - lost)
	substance_changed.emit()
	return lost


func spend(amount: int) -> bool:
	if banked_substance < amount:
		return false
	banked_substance -= amount
	persist()
	substance_changed.emit()
	return true


func restore_patch(id: String) -> void:
	if not restored_patches.has(id):
		restored_patches.append(id)
		persist()
		substance_changed.emit()


func is_restored(id: String) -> bool:
	return restored_patches.has(id)
