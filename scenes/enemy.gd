extends CharacterBody2D

@export var player: CharacterBody2D
@export var speed: int = 50
@export var chase_speed: int = 150
@export var acceleration: int = 300

@onready var sprite: Sprite2D = $Sprite2D
@onready var ray_cast: RayCast2D = $Sprite2D/RayCast2D
@onready var timer: Timer = $Timer

var gravity: float = ProjectSettings.get_setting('physics/2d/default_gravity')
var direction: Vector2
var right_bound: Vector2
var left_bound: Vector2

enum states{
	Wander,
	Chase
}

var current_state = states.Wander

func _ready():
	left_bound = self.position + Vector2(-125,0)
	right_bound = self.position + Vector2(125,0)
	
func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	handle_movement(delta)
	change_direction()
	look_for_player()
	
func look_for_player():
	if ray_cast.is_colliding():
		var colider = ray_cast.get_collider()
		if colider == player:
			chase_player()
		elif current_state == states.Chase:
			stop_chase()
	elif current_state == states.Chase:
		stop_chase()
		
func chase_player() -> void:
	timer.stop()
	current_state = states.Chase

func stop_chase() -> void:
	if timer.time_left <= 0:
		timer.start()

func handle_movement(delta:float) -> void:
	if current_state == states.Wander:
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(direction * chase_speed, acceleration * delta)

func change_direction() -> void:
	if current_state == states.Wander:
		if sprite.flip_h:
			if self.position.x <= right_bound.x:
				direction = Vector2(1,0)
			else:
				sprite.flip_h = false
				ray_cast.target_position = Vector2(-125,0)
		else:
			if self.position.x >= left_bound.x:
				direction = Vector2(-1,0)
			else:
				sprite.flip_h = true
				ray_cast.target_position = Vector2(125,0)
	else:
		direction = (player.position - self.position).normalized()
		direction = sign(direction)
		if direction.x ==1:
			sprite.flip_h = true
			ray_cast.target_position = Vector2(125,0)
		else:
			sprite.flip_h = false
			ray_cast.target_position = Vector2(-125,0)
			
func handle_gravity(delta:float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
func _on_timer_timeout() -> void:
	current_state = states.Wander
