extends Node2D

enum OreType {
	COPPER = 2,
	IRON = 4,
	GOLD = 8,
	DIAMOND = 12,
	SPACE_ROCK = 0
}

export(OreType) var type

func _ready():
	if(type == null): type = OreType.SPACE_ROCK
	drawOre()

func drawOre():
	get_node("Sprite").modulate = Color(1.0, 1.0, 1.0, 1.0)
	get_node("Sprite").modulate = Color(type / 255.0, type / 255.0 * 10, type / 255.0, 1.0)