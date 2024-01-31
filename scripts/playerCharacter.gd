extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -350.0

@onready var sprite_2d = $AnimatedSprite2D
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if (Global.game_running):
		#animations
		if ( velocity.x >1 || velocity.x < -1):
			sprite_2d.play("running")
			
		else:
			sprite_2d.play("default")
		
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta
			Global.jumping = true
			sprite_2d.play("jumping")

		# Handle jump.
		if not is_on_floor() and velocity.y  > 0:
			Global.jumping = true
			sprite_2d.play("falling")
			
		if is_on_floor():
			Global.jumping = false
			
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			Global.jumping = true

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, 10)

		move_and_slide()
		
		var isLeft =  velocity.x < 0
		
		sprite_2d.flip_h = isLeft
