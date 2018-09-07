extends Node2D

enum OreType {
	COPPER = 5,
	IRON = 10,
	GOLD = 40,
	DIAMOND = 100,
	SPACE_ROCK = 0
}

export(OreType) var type

func _ready():
	if(type == null): type = OreType.SPACE_ROCK
	print(type)
	drawOre()

func drawOre():
	get_node("Sprite").modulate = Color(type / 255.0, type / 255.0 * 10, type / 255.0, 1.0)