extends "res://entities/npc/npc.gd"

enum STATE { MOVE, ATTACK, HURT }

const SPEED = 64

onready var animations = $samuraiAnimations
onready var ray = $samuraiRay

var currentState = STATE.MOVE
var target = null
var team = null

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	if !get_parent().get_parent().startEvent:
		return
	else:
		animations.play()

	if currentState == STATE.MOVE:
		if !target:
			if animations.flip_h:
				self.direction = Vector2(-1, 0)
				ray.rotation_degrees = 180
			else:
				self.direction = Vector2(1, 0)
				ray.rotation_degrees = 0
		else:
			if self.global_position.y < target.global_position.y:
				self.direction.y = 1
			elif self.global_position.y > target.global_position.y:
				self.direction.y = -1
			elif self.global_position.y == target.global_position.y:
				self.direction.y = 0

			if animations.flip_h && target.global_position.x > self.global_position.x:
				animations.flip_h = false
				self.direction.x = 1
			elif !animations.flip_h && target.global_position.x < self.global_position.x:
				animations.flip_h = true
				self.direction.x = -1
			elif self.global_position.x == target.global_position.x:
				self.direction.x = 0

			if animations.flip_h == true:
				ray.rotation_degrees = 180
			else:
				ray.rotation_degrees = 0

		collisionObject = self.move_and_collide(self.direction.normalized() * SPEED * delta)

		if ray.is_colliding() && !ray.get_collider().is_in_group(team):
			currentState = STATE.ATTACK
			animations.set_animation("sword")
			animations.play()
			self.direction = Vector2()

# setTeam
# Sets the samurai team color and modulate
func setTeam(color):
	if color == "blue":
		self.add_to_group(color)
		team = color
		self.modulate = Color("4c93ad")
	elif color == "red":
		self.add_to_group(color)
		team = color
		self.modulate = Color("c93038")

# takeDamage
# Decreases hp and removes from queue when dead
func takeDamage():
	hp -= 1

	if hp <= 0:
		self.queue_free()
	else:
		currentState = STATE.HURT
		animations.play("hurt")

# Signals

func _on_samuraiAnimations_animation_finished():
	if currentState == STATE.ATTACK || currentState == STATE.HURT:
		currentState = STATE.MOVE
		animations.set_animation("walkSwordSide")
		animations.play()

func _on_samuraiAnimations_frame_changed():
	# Determines if entity stands close enough to attack animation to take damage
	if currentState == STATE.ATTACK && ray.is_colliding() && ray.get_collider().is_in_group("entities") && animations.get_frame() == 5:
		ray.get_collider().takeDamage()

func _on_samuraiDetectArea_body_entered(body):
	if !body.is_in_group(team) && !target:
		target = body
