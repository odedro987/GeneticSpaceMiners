extends KinematicBody2D

var velocity = Vector2(0, 0)

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	#get_node("Sprite").rotation = 0 if get_node("Sprite").rotation >= 360 else get_node("Sprite").rotation + delta
	move_and_collide(velocity * speed * delta)
	seek(get_global_mouse_position())

func seek(target):
	global_rotation_degrees = rad2deg(global_position.angle_to_point(target)) - 90
	velocity = (target - global_position)