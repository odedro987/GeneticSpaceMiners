extends Node

var ore = load("res://Entities/Ore.tscn")
var miner = load("res://Entities/SpaceMiner.tscn")
var ores = []
var miners = []

func _ready():
	randomize()
	GameState.connect("on_ore_mined", self, "removeOre")
	GameState.connect("on_miner_died", self, "removeMiner")
	for i in range(50):
		var tempOre = ore.instance()
		add_child(tempOre)
		tempOre.global_position = Vector2(randi() % 1500, randi() % 1000)
		tempOre.type = tempOre.OreType.values()[randi() % tempOre.OreType.keys().size()]
		tempOre.drawOre()
		ores.push_back(tempOre)
	for i in range(4):
		var tempMiner = miner.instance()
		add_child(tempMiner)
		miners.push_back(tempMiner)
		tempMiner.global_position = Vector2(randi() % 1500, randi() % 1000)
	set_process(true)

func _process(delta):
	for miner in miners:
		miner.eat(ores, delta)

func removeOre(ore):
	ores.remove(ores.find(ore))
	remove_child(ore)
	
func removeMiner(miner):
	miners.remove(miners.find(miner))
	remove_child(miner)