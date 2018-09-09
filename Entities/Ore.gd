extends Node2D

enum ResourceType {
	COPPER = 2,
	IRON = 4,
	GOLD = 8,
	SPACE_ROCK = -2,
	METAL_SCRAPE = -4
}

export(ResourceType) var type

func _ready():
	if(type == null): type = ResourceType.SPACE_ROCK
	loadSprite()

func getSpriteByType():
	if(type == ResourceType.COPPER): return "res://Assets/Copper.png"
	elif(type == ResourceType.IRON): return "res://Assets/Iron.png"
	elif(type == ResourceType.GOLD): return "res://Assets/Gold.png"
	elif(type == ResourceType.SPACE_ROCK): return "res://Assets/SpaceRock.png"
	elif(type == ResourceType.METAL_SCRAPE): return "res://Assets/MetalScrap.png"
	else: return ""

func loadSprite():
	get_node("Sprite").texture = load(getSpriteByType())