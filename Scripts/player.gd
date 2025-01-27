extends CharacterBody3D
@onready var player: CharacterBody3D = $"."

@onready var nek: Node3D = $nek
@onready var camera_3d: Camera3D = $nek/head/eyes/Camera3D
@onready var head: Node3D = $nek/head
@onready var standing_collision_shape: CollisionShape3D = $standing_collision_shape
@onready var crouching_collision_shape: CollisionShape3D = $crouching_collision_shape
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var eyes: Node3D = $nek/head/eyes
@onready var animation_player: AnimationPlayer = $nek/head/eyes/AnimationPlayer
@onready var interaction: RayCast3D = $nek/head/eyes/Camera3D/Interaction
@onready var hand: Marker3D = $nek/head/eyes/Camera3D/hand
@onready var joint: Generic6DOFJoint3D = $nek/head/eyes/Camera3D/Generic6DOFJoint3D
@onready var staticbody: StaticBody3D = $nek/head/eyes/Camera3D/StaticBody3D
@onready var footstep: AudioStreamPlayer3D = $Footstep
@onready var water_sound: AudioStreamPlayer3D = $WaterSound
@onready var jumping: AudioStreamPlayer3D = $Jumping
@onready var landing: AudioStreamPlayer3D = $Landing
@onready var slide: AudioStreamPlayer3D = $Slide
@onready var object_pickup: AudioStreamPlayer3D = $ObjectPickup
@onready var object_throw: AudioStreamPlayer3D = $ObjectThrow
@onready var water: MeshInstance3D = $"../Water"
@onready var box: RigidBody3D = $"../box"
@onready var object_splash: AudioStreamPlayer3D = $"../ObjectSplash"
@onready var hurt_overlay: TextureRect = $HurtOverlay
@onready var health_bar: ProgressBar = $HealthBar
@onready var damage_sound: AudioStreamPlayer3D = $DamageSound

var hurt_tween : Tween

var picked_object
var pull_power = 4
var rotation_power = 0.05
var locked = false
var current_speed = 5.0
const walking_speed = 5.0
const sprinting_speed = 8.0
const crouching_speed = 3.0
var last_velocity = Vector3.ZERO
var climbing_speed = 150.0
var water_speed = 1.5
var slide_timer = 0.0
var slide_timer_max = 1.0
var slide_vector = Vector2.ZERO
var slide_speed = 10.0
var played_sound = false
var walking = false
var sprinting = false
var crouching = false
var free_looking = false
var sliding = false
var free_look_tilt_amount = 8.5
const jump_velocity = 5
var lerp_speed = 10.0
var air_lerp_speed = 3.0
const mouse_sens = 0.25
var crouching_depth = -0.5
var direction = Vector3.ZERO
const head_bobbing_sprinting_speed = 22.0
const head_bobbing_walking_speed = 14.0
const head_bobbing_crouching_speed = 10.0
const head_bobbing_sprinting_intensity = 0.2
const head_bobbing_walking_intensity = 0.1
const head_bobbing_crouching_intensity = 0.05
var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_current_intensity = 0.0
var water_entered = false
var buoyancy_force = Vector3(0, 5000, 0)  # Buoyancy force for the box
var water_surface_height = 0.0  # Height of the water's surface (you can adjust this depending on your scene)

# Fall damage threshold (you can adjust this value)
const FALL_DAMAGE_THRESHOLD = -12.0
var health_regen_rate = 0.5 # Health restored per second
var health_regen_timer = 0.0
var max_health = 100.0
var current_health = max_health 
##Health variables



## Fall damage

##Swim variables
var swim_speed = 4
var swim_input = false


###handle box force
var push_force = 3.0

##Handle wall ride
@onready var wall_normal = Vector3()
var direction_w = Vector3()
var speed = 10
var wallrunning = false
var wall_run_timer: float = 0.0
const max_wall_run_time: float = 1.5
var wall_run_complete = false
@onready var wall_run_bar: ProgressBar = $WallRunBar
var wallrun_jump_force = 100.0  # Adjust this to control the strength of the jump off the wall
var wallrun_jump_direction = Vector3()  # Direction for the wall jump


##wall jump cooldown
var wall_jump_count = 0
var wall_jump_cooldown = 10.0
var can_wall_jump = true
var cooldown_timer
@onready var wall_jump_bar: ProgressBar = $WallJumpBar
var wall_jump_regeneration_timer: float = 0.0  
var wall_jump_regeneration_interval: float = 1.0  


##water rise vars
var rising_speed: float = 0.001
var target_height: float = 10.0


##box timer
var box_timer = 0.0
var box_has_touched = false
var box_time = 5.0



func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		$PauseMenu.pause()



func _ready():
	box.connect("bodycollided", Callable(player, "_on_body_collided"))
	# Set the hurt_overlay to be invisible at the start
	hurt_overlay.modulate = Color.TRANSPARENT
	interaction.collision_mask = 2
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	water_surface_height = water.position.y
	if box:
		
		# Set water surface height (could be dynamic if the water moves up/down)
		water_surface_height = water.position.y
	
	wall_jump_count = 9
	wall_jump_bar.value = wall_jump_count
func _play_footstep_audio():
	if water_entered:
		if !water_sound.playing:
			water_sound.pitch_scale = randf_range(0.8, 1.2)
			water_sound.play()
	else:
		if sprinting:
			footstep.pitch_scale = randf_range(1.2, 1.5)
			footstep.play()
		elif crouching:
			footstep.pitch_scale = randf_range(0.4, 0.6)
			footstep.play()
		else:
			footstep.pitch_scale = randf_range(0.5, 0.7)
			footstep.play()
func _process(delta: float) -> void:
	var look_direction = -camera_3d.global_transform.basis.z
	
	look_direction = look_direction.normalized()
	
	
func pick_object():
	var collider = interaction.get_collider()
	if collider != null and collider is RigidBody3D:
		picked_object = collider
		
		
		
		joint.set_node_b(picked_object.get_path())
		object_pickup.play()

func rotate_object(event):
	if picked_object != null:
		if event is InputEventMouseMotion:
			staticbody.rotate_x(deg_to_rad(event.relative.y * rotation_power))
			staticbody.rotate_y(deg_to_rad(event.relative.x * rotation_power))

func remove_object():
	if picked_object != null:
		
		picked_object.linear_velocity = Vector3.ZERO
		picked_object.angular_velocity = Vector3.ZERO
		picked_object = null
		
		joint.set_node_b(joint.get_path())
		

		
		
func perform_wall_jump():
	if can_wall_jump and wall_jump_count > 0:
		if wallrunning:
			var wall_jump_direction = -wall_normal.normalized()	
			velocity = wall_jump_direction * wallrun_jump_force
			velocity.y = jump_velocity
			
			wallrunning = false
			
			wall_run_timer = 0.0
			wall_run_bar.value = 0.0
			wall_jump_count -= 1
			wall_jump_bar.value = wall_jump_count
			jumping.play()
			animation_player.play("jump")
			
		else:
			wall_run_complete = false
	elif wall_jump_count <= 0:
		can_wall_jump = false
		cooldown_timer = wall_jump_cooldown
		print("Wait 3 seconds")
				
					
				
func wall_run():
	if wall_run_complete:
		return
		
	if is_on_wall() and !is_on_floor() and Input.is_action_pressed("forward"):
		if wall_run_timer <= max_wall_run_time:
			velocity.y = 0
			wallrunning = true
			wall_run_timer += get_process_delta_time()
			wall_run_bar.value = wall_run_timer / max_wall_run_time
		else:
			wallrunning = false
			
			
			
			wall_run_bar.value = 0.0
	elif is_on_floor() and wall_run_complete:
		
		wallrunning = false
		wall_run_timer = 0.0
		wall_run_complete = false
		wall_run_bar.value = 0.0
	elif !is_on_wall():
		
		wall_run_complete = false
		wall_run_timer = 0.0
		wall_run_bar.value = 0.0
func _input(event):
	if Input.is_action_just_pressed("interact"):
		if picked_object == null:
			
			pick_object()
		elif picked_object != null:
			remove_object()
		elif picked_object != null and is_on_wall():
			print("object collided")
			remove_object()
	if Input.is_action_pressed('rclick'):
		locked = true
		rotate_object(event)
		
	if Input.is_action_just_released('rclick'):
		locked = false
		
	
	
	if event is InputEventMouseMotion:
		if free_looking:
			nek.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			nek.rotation.y = clamp(nek.rotation.y, deg_to_rad(-120), deg_to_rad(120))
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta: float) -> void:
	if picked_object != null:
		var camera_position = camera_3d.global_transform.origin
		var camera_direction = -camera_3d.global_transform.basis.z
		
		var distance = 2.5
		var target_position = camera_position + camera_direction * distance
		
		var vertical_offset = 1
		target_position.y -= vertical_offset
		
		
		picked_object.global_transform.origin = target_position
		picked_object.global_transform.basis = camera_3d.global_transform.basis
	##Health regen logic
	if !can_wall_jump:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			can_wall_jump = true
			wall_jump_count = 9
			wall_jump_bar.value = wall_jump_count
			print("cooldown finished jump again")
	
	if wall_jump_count < 9:
		wall_jump_regeneration_timer += delta
		if wall_jump_regeneration_timer >= wall_jump_regeneration_interval:
			wall_jump_count += 0.2
			wall_jump_bar.value = wall_jump_count
			wall_jump_regeneration_timer = 0.0
	
	if wallrunning and Input.is_action_just_pressed('jump'):
		perform_wall_jump()
	
	health_regen_timer -= delta
	
	wall_run()
	
	if health_regen_timer <= 0.0 and current_health < max_health:
		current_health += health_regen_rate
		
		health_bar.value = current_health
		health_regen_timer = 1.0
	
	
	# Add water damage logic here
	var water_damage_timer : float = 0.0
	var water_damage_interval : float = 1.0  # Damage interval in seconds
	##player height
	var player_height = global_position.y
	
	
	if water_entered:
		
		
			
		current_speed = water_speed
		water_damage_timer -= delta  # Decrease the timer

		# Apply damage every 'water_damage_interval' seconds
		if water_damage_timer <= 0:
			hurt(0.2)  # Call the hurt function to apply 20 damage
			water_damage_timer = water_damage_interval  # Reset the timer
	
	# Handle crouch, sprint, walk, etc. as usual
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var is_moving = input_dir != Vector2.ZERO || velocity.length() > 0.1
	
	if Input.is_action_pressed("crouch") || sliding:
		head.position.y = lerp(head.position.y, 1.8 + crouching_depth, delta*lerp_speed)
		current_speed = lerp(current_speed, crouching_speed, delta * lerp_speed)
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
		
		if sprinting && input_dir != Vector2.ZERO:
			sliding = true
			slide_timer = slide_timer_max
			slide_vector = input_dir
			free_looking = true
			
		
		walking = false
		sprinting = false
		crouching = true
		
	elif !ray_cast_3d.is_colliding():
		crouching_collision_shape.disabled = true
		standing_collision_shape.disabled = false
		head.position.y = lerp(head.position.y, 0.0, delta*lerp_speed)
		head.position.y = 1.8
		if Input.is_action_pressed("sprint"):
			current_speed = lerp(current_speed, sprinting_speed, delta * lerp_speed)
			walking = false
			sprinting = true
			crouching = false
		else:
			current_speed = lerp(current_speed, walking_speed, delta * lerp_speed)
			walking = true
			sprinting = false
			crouching = false
	
	if Input.is_action_pressed("free_look") || sliding:
		free_looking = true
		if sliding:
			eyes.rotation.z = lerp(eyes.rotation.z, -deg_to_rad(7.0), delta * lerp_speed)
		else:
			eyes.rotation.z = -deg_to_rad(nek.rotation.y * free_look_tilt_amount)
	else:
		free_looking = false
		nek.rotation.y = lerp(nek.rotation.y, 0.0, delta*lerp_speed)
		eyes.rotation.z = lerp(eyes.rotation.z, 0.0, delta*lerp_speed)
	
	if is_on_floor() and !sliding:
		if is_moving and !footstep.playing:
			_play_footstep_audio()
		elif !is_moving and footstep.playing:
			footstep.stop()
	
	if sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			sliding = false
			
			slide.stop()
			free_looking = false
			played_sound = false
		elif played_sound == false:
			played_sound = true
			slide.play()
	
	# Handle headbob
	if sprinting:
		head_bobbing_current_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed*delta
	elif walking:
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed*delta
	elif crouching:
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_crouching_speed*delta
	
	if is_on_floor() && !sliding && input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2)+0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y*(head_bobbing_current_intensity/2.0), delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x*head_bobbing_current_intensity, delta*lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta*lerp_speed)
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		
		velocity.y = jump_velocity
		
		sliding = false
		animation_player.play("jump")
		jumping.play()

	# Handle landing and fall damage
	if is_on_floor():
		if last_velocity.y < 0.0:
			if last_velocity.y < FALL_DAMAGE_THRESHOLD:
				print(last_velocity.y)
				if last_velocity.y > -15:
					
					print(last_velocity.y, "taken less")
					hurt(20)  
				elif velocity.y < -15:
					hurt(45)
				elif last_velocity.y < -20:
					print(last_velocity.y, "taken more")
					hurt(75)
			landing.play()
			animation_player.play("landing")
			if jumping.playing:
				jumping.stop()

	# Get the input direction and handle the movement/deceleration
	if is_on_floor():
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*lerp_speed)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*air_lerp_speed)
	
	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x, 0, slide_vector.y)).normalized()
		current_speed = (slide_timer + 0.1) * slide_speed
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	if picked_object != null:
		var a = picked_object.global_transform.origin
		var b = hand.global_transform.origin
		picked_object.set_linear_velocity((b-a)*pull_power)
	
	last_velocity = velocity
	
	if player_height < water_surface_height:
		
		water_entered = true
	else:
		water_entered = false
	
	if Input.is_action_pressed("swim") and water_entered:
		
		hurt(0.8)
		
		velocity.y = swim_speed
	elif water_entered and !Input.is_action_pressed("swim"):
		velocity.y = -1
	
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			print("wall resistance")
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
# Hurt function to handle the hurt_overlay visibility
func hurt(damage : float):
	damage_sound.play()
	current_health -= damage
	health_bar.value = current_health
	
	if health_bar.value <= 0:
		get_tree().reload_current_scene()
	
	hurt_overlay.modulate = Color.WHITE
	if hurt_tween:
		hurt_tween.kill()
	hurt_tween = create_tween()
	hurt_tween.tween_property(hurt_overlay, "modulate", Color.TRANSPARENT, 0.5)
	


# Handle water entry
func _on_sound_detection_body_entered(body: Node3D) -> void:
	if body == box:
		
		object_splash.play()
		if body is RigidBody3D:
			body.gravity_scale = 0  # Disable gravity while it's underwater
			body.apply_impulse(Vector3.ZERO, buoyancy_force)

	if body.name == "player":
		water_entered = true
		object_splash.play()
		current_speed = water_speed
		
func _on_water_surface_changed(new_height: float):
	water_surface_height = new_height
	

# Handle water exit
func _on_sound_detection_body_exited(body: Node3D) -> void:
	if body == box:
		
		if body is RigidBody3D:
			body.gravity_scale = 1  # Restore gravity when it exits the water
			body.apply_impulse(Vector3.ZERO, Vector3(0, -20, 0))  # Small downward force if needed

	if body.name == "player":
		water_entered = false
		current_speed = walking_speed
		


func rise_water() -> void:
	
	while water.position.y < target_height:
		water.position.y += rising_speed
		water_surface_height = water.position.y
		
		await get_tree().create_timer(0.0).timeout

func _on_particle_detection_body_entered(body: Node3D) -> void:
	if body.name == "player":
		
		rise_water()
	elif body.name == "box":
		print("box entered sphere")





func _on_area_3d_body_entered(body: Node3D) -> void:
	
	if body.name == "box":
		var look_direction = -camera_3d.global_transform.basis.z
		var looking_down = look_direction.y < 0
		
		if looking_down and !is_on_floor():
			if picked_object == body:
				print("removing object!", look_direction.y)
				remove_object()
		
		
		
			
		
		body.set_collision_layer_value(1, true)
		body.set_collision_layer_value(2, true)
		box_has_touched = true
		body.set_collision_mask_value(1, true)
		
#func _process(delta: float) -> void:
	#if box_has_touched:
		#box_timer += delta
		#if box_timer >= box_time:
			#timer_end() 		
#
#func timer_end():
	#print("timer reset")
	#box_has_touched = false
	#box_timer = 0.0
#
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "box":
		body.set_collision_layer_value(1, false)
		body.set_collision_layer_value(2, true)
		box_has_touched = false
		body.set_collision_mask_value(1, true)

func _on_body_collided(body):
	pass
