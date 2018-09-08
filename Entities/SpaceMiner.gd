extends KinematicBody2D

const MAX_SPEED = 800
const FRICTION = 0.95
const MAX_FUEL = 50.0
var acceleration = Vector2(0, 0)
var velocity = Vector2(0, 0)

var fuel = MAX_FUEL
var fuelLeak = 0.05

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	checkCollisions()
	stayInBounds()
	modulateFuel()
	fuel -= fuelLeak
	if(isDead()):
		GameState.miner_died(self)
	move_and_collide(velocity * delta)

func eat(list, delta):
	var closest = -1
	var minDistance = 10000
	for target in list:
		var distance = global_position.distance_to(target.global_position)
		if(distance < minDistance):
			minDistance = distance
			closest = target
	if(list.size() > 0):
		seek(closest, delta)

func seek(target, delta):
	global_rotation_degrees = rad2deg(global_position.angle_to_point(target.global_position)) - 90
	steer(target, delta)

func steer(target, delta):
	var toTarget = (target.global_position - global_position).normalized()
	velocity += toTarget * MAX_SPEED * delta
	velocity *= pow(FRICTION, delta * 60.0)
	
	if(velocity.x > MAX_SPEED): velocity.x = MAX_SPEED
	if(velocity.y > MAX_SPEED): velocity.y = MAX_SPEED
	if(velocity.x < -MAX_SPEED): velocity.x = -MAX_SPEED
	if(velocity.y < -MAX_SPEED): velocity.y = -MAX_SPEED

func checkCollisions():
	for object in get_node("OreCollectionArea").get_overlapping_bodies():
		if(object.name.to_lower().find("ore") != -1):
			fuel += object.type if fuel < MAX_FUEL else 0
			GameState.ore_mined(object)

func isDead():
	return fuel <= 0

func stayInBounds():
	if(global_position.x < 0 || global_position.x > OS.window_size.x):
		velocity.x *= -1
	if(global_position.y < 0 || global_position.y > OS.window_size.y):
		velocity.y *= -1

func modulateFuel():
	var g = Color(0.0, 1.0, 0.0, 1.0)
	var r = Color(1.0, 0.0, 0.0, 1.0)
	get_node("Sprite").modulate = g.linear_interpolate(r, 1 - fuel / MAX_FUEL)