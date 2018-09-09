extends KinematicBody2D

const FRICTION = 0.95
const MAX_FUEL = 20.0
const RANDOM_STEER_TIME = 6.0
const FUEL_LEAK = 0.05
const RADIUS_RANGE = Vector2(50, 250)
const CLONE_RATE = 4000

var acceleration = Vector2(0, 0)
var velocity = Vector2(0, 0)

var fuel = MAX_FUEL
var maxSpeed = 800
var resourceWeights = { }
var resourceRadii = { }
var steerToRandom = Vector2(0, 0)
var randomSteerTimer = 0

var shouldClone = 0
var knownResourceTypes = {}

func _ready():
	steerToRandom = Vector2(randi() % int(OS.window_size.x), randi() % int(OS.window_size.y))
	set_physics_process(true)

func _physics_process(delta):
	checkCollisions()
	stayInBounds()
	modulateFuel()
	fuel -= FUEL_LEAK
	clone()
	if(isDead()):
		GameState.miner_died(self)
	move_and_collide(velocity * delta)

func mine(list, delta):
	var closest = null
	var minDistance = 10000
	for target in list:
		var distance = global_position.distance_to(target.global_position)
		if(distance < minDistance && distance <= resourceRadii[str(target.type)]):
			minDistance = distance
			closest = target
	if(closest != null && list.size() > 0):
		seek(closest, delta)
	else:
		randomSteer(delta)

func seek(target, delta):
	var lookAt = 0 if resourceWeights[str(target.type)] > 0 else 180
	global_rotation_degrees = (rad2deg(global_position.angle_to_point(target.global_position)) - 90) + lookAt
	steer(target, delta)

func steer(target, delta):
	var toTarget = (target.global_position - global_position).normalized()
	velocity += toTarget * maxSpeed * delta * resourceWeights[str(target.type)]
	velocity *= pow(FRICTION, delta * 60.0)
	
	if(velocity.x > maxSpeed): velocity.x = maxSpeed
	if(velocity.y > maxSpeed): velocity.y = maxSpeed
	if(velocity.x < -maxSpeed): velocity.x = -maxSpeed
	if(velocity.y < -maxSpeed): velocity.y = -maxSpeed

func randomSteer(delta):
	randomSteerTimer += delta
	if(randomSteerTimer >= RANDOM_STEER_TIME || global_position.distance_to(steerToRandom) <= 5):
		steerToRandom = Vector2(randi() % int(OS.window_size.x), randi() % int(OS.window_size.y))
		randomSteerTimer = 0
	var toTarget = (steerToRandom - global_position).normalized()
	velocity += toTarget * maxSpeed * delta
	velocity *= pow(FRICTION, delta * 60.0)
	global_rotation_degrees = (rad2deg(global_position.angle_to_point(steerToRandom)) - 90)
	
	if(velocity.x > maxSpeed): velocity.x = maxSpeed
	if(velocity.y > maxSpeed): velocity.y = maxSpeed
	if(velocity.x < -maxSpeed): velocity.x = -maxSpeed
	if(velocity.y < -maxSpeed): velocity.y = -maxSpeed

func checkCollisions():
	for object in get_node("OreCollectionArea").get_overlapping_bodies():
		if(object.name.to_lower().find("ore") != -1):
			fuel += object.type if fuel < MAX_FUEL else 0
			GameState.ore_mined(object)

func isDead():
	return fuel <= 0

func clone():
	shouldClone = randi() % CLONE_RATE
	if(shouldClone < 5):
		var clone = load("res://Entities/SpaceMiner.tscn").instance()
		clone.global_position = global_position
		clone.knownResourceTypes = knownResourceTypes
		clone.resourceWeights = resourceWeights
		clone.resourceRadii = resourceRadii
		clone.fuel = clone.MAX_FUEL
		var mutate = randi() % 100
		clone.maxSpeed = maxSpeed if mutate < 10 else rand_range(maxSpeed - 100, maxSpeed + 100)
		for i in resourceRadii.keys():
			mutate = randi() % 100
			if(mutate < 10):
				clone.resourceRadii[i] += rand_range(-50, 50)
		for i in resourceWeights.keys():
			mutate = randi() % 100
			if(mutate < 10):
				clone.resourceWeights[i] *= -1
		GameState.miner_cloned(clone)

func stayInBounds():
	if(global_position.x < 0 || global_position.x > OS.window_size.x):
		velocity.x *= -1
	if(global_position.y < 0 || global_position.y > OS.window_size.y):
		velocity.y *= -1

func modulateFuel():
	var g = Color(0.0, 1.0, 0.0, 1.0)
	var r = Color(1.0, 0.0, 0.0, 1.0)
	get_node("Sprite").modulate = g.linear_interpolate(r, 1 - fuel / MAX_FUEL)

func initResourceInfo(resources):
	knownResourceTypes = resources
	for i in range(knownResourceTypes.size()):
		resourceWeights[str(knownResourceTypes[i])] = 1 if randi() % 2 == 0 else -1
		resourceRadii[str(knownResourceTypes[i])] = int(rand_range(RADIUS_RANGE.x, RADIUS_RANGE.y))

func setResourceInfo(weights, radii):
	for i in range(weights.size()):
		resourceWeights[str(knownResourceTypes[i])] = weights[i]
		resourceRadii[str(knownResourceTypes[i])] = radii[i]