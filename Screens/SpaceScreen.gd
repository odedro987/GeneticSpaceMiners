extends Node

const RESOURCE_TIME = 0.5

var resource = load("res://Entities/Ore.tscn")
const RESOURCE = preload("res://Entities/Ore.gd")
var miner = load("res://Entities/SpaceMiner.tscn")
var resources = []
var miners = []

var spawnResourceTimer = 0.0

func _ready():
	randomize()
	GameState.connect("on_ore_mined", self, "removeResource")
	GameState.connect("on_miner_died", self, "removeMiner")
	GameState.connect("on_miner_cloned", self, "addMiner")
	spawnResources(100)
	spawnMiners(20)
	set_process(true)

func spawnResources(amount):
	for i in range(amount):
		spawnResource(1500, 1000)

func spawnMiners(amount):
	for i in range(amount):
		var tempMiner = miner.instance()
		add_child(tempMiner)
		miners.push_back(tempMiner)
		tempMiner.global_position = Vector2(randi() % 1500, randi() % 1000)
		tempMiner.initResourceInfo(RESOURCE.ResourceType.values())

func _process(delta):
	runTimers(delta)
	for miner in miners:
		miner.mine(resources, delta)
	if(Input.is_action_just_released("ui_up")):
		spawnResources(5)
	if(Input.is_action_just_released("ui_down")):
		spawnMiners(1)

func runTimers(delta):
	spawnResourceTimer += delta
	if(spawnResourceTimer >= RESOURCE_TIME):
		spawnResourceTimer = 0
		spawnResource(1500, 1000)

func spawnResource(rangeX, rangeY, randomFlag=true):
	var tempResource = resource.instance()
	add_child(tempResource)
	tempResource.global_position = Vector2(randi() % rangeX, randi() % rangeY) if randomFlag else Vector2(rangeX, rangeY)
	tempResource.type = tempResource.ResourceType.values()[randi() % tempResource.ResourceType.keys().size()]
	tempResource.loadSprite()
	resources.push_back(tempResource)
	
func removeResource(resource):
	resources.remove(resources.find(resource))
	remove_child(resource)

func addMiner(newMiner):
	miners.push_back(newMiner)
	add_child(newMiner)
	
func removeMiner(miner):
	var minerPos = miner.global_position
	miners.remove(miners.find(miner))
	remove_child(miner)
	spawnResource(minerPos.x, minerPos.y, false)