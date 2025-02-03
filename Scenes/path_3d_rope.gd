extends Path3D
# Script by Elijah Martin/Palin_drome

@export_range(1, 200, 1) var number_of_segments = 10
@export_range(3, 50, 1) var mesh_sides = 6
@export var cable_thickness = 0.05
@export var fixed_start_point = true
@export var fixed_end_point = true
@export var rigidbody_attached_to_start : RigidBody3D
@export var rigidbody_attached_to_end : CharacterBody3D
@export var material : Material
@export var speed_factor : float = 0.7  # Adjust the speed of rope movement

@onready var mesh := $CSGPolygon3D
@onready var distance = curve.get_baked_length()

var player_joint : PinJoint3D = null
var player_attached : bool = false
@onready var player: CharacterBody3D = $"../player"

# instances
var segments : Array
var joints : Array
var curve_points : Array



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# store position and rotation
	var rotation_buffer = rotation
	rotation = Vector3(0, 0, 0)
	var position_buffer = position
	position = Vector3(0, 0, 0)
	
	# CSG Mesh shape array
	var myShape : PackedVector2Array
	for i in range(number_of_segments + 1):
		curve_points.append(curve.sample_baked((distance * (i)) / (number_of_segments), true))
	curve.clear_points()

	# create cable segments
	for i in range(number_of_segments):
		# create rigidbodies
		segments.append(RigidBody3D.new())
		self.add_child(segments[i])
		
		# position rigidbodies between the joints
		segments[i].position = curve_points[i] + (curve_points[i+1] - curve_points[i]) / 2
		
		# create collision shape 3Ds
		segments[i].add_child(CollisionShape3D.new())
		segments[i].get_child(0).shape = CapsuleShape3D.new()
		segments[i].get_child(0).shape.radius = cable_thickness
		segments[i].get_child(0).shape.height = (curve_points[i+1] - curve_points[i]).length()
		
		# small offset added to prevent Vector UP
		segments[i].look_at_from_position(curve_points[i] + (curve_points[i+1] - curve_points[i]) / 2 + Vector3(0.001, 0, -0.001), curve_points[i+1])
		segments[i].rotation.x += PI / 2
		
		# create pin joints
		if i == 0 and fixed_start_point:
			joints.append(PinJoint3D.new())
			self.add_child(joints[i])
			joints[i].position = curve_points[i]
		else:
			joints.append(PinJoint3D.new())
			self.add_child(joints[i])
			joints[i].position = curve_points[i]
			joints[i].node_a = segments[i-1].get_path()
			joints[i].node_b = segments[i].get_path()
		
		curve.add_point(curve_points[i])
	
	curve.add_point(curve_points[number_of_segments])

	# setup mesh array
	for i in range(mesh_sides):
		myShape.append(Vector2(sin(2 * PI * (i + 1) / mesh_sides), cos(2 * PI * (i + 1) / mesh_sides)) * cable_thickness)
	
	# setup mesh
	mesh.polygon = myShape
	if material != null:
		mesh.material = material

	# restore position and rotation
	rotation = rotation_buffer
	# lock joints and segments position and rotation
	for segment in segments:
		segment.top_level = true
		segment.position += position_buffer
	for joint in joints:
		joint.top_level = true
		joint.position += position_buffer

	# fix start point
	rotation = Vector3(0, 0, 0)
	if fixed_start_point:
		joints[0].node_b = segments[0].get_path()
	if fixed_end_point:
		joints.append(PinJoint3D.new())
		self.add_child(joints[-1])
		joints[-1].position = curve_points[-1] + position_buffer
		joints[-1].node_a = segments[number_of_segments - 1].get_path()

	# attach rigid bodies if they exist
	if rigidbody_attached_to_start != null:
		joints[0].node_b = rigidbody_attached_to_start.get_path()
	if rigidbody_attached_to_end != null:
		if fixed_end_point == false:
			joints.append(PinJoint3D.new())
			self.add_child(joints[-1])
			joints[-1].position = curve_points[-1] + position_buffer
			joints[-1].node_a = segments[-1].get_path()
		joints[-1].node_b = rigidbody_attached_to_end.get_path()


func _physics_process(_delta: float) -> void:
	# Adjust the movement of the segments based on the speed_factor without altering their positions
	for p in range(curve.point_count):
		if p < number_of_segments:
			# Calculate the segment's current position and velocity
			var segment_offset = segments[p].position + segments[p].transform.basis.y * segments[p].get_child(0).shape.height / 2
			# Update the curve point based on the segment's movement, without scaling the position
			var movement = segment_offset - curve.get_point_position(p)
			curve.set_point_position(p, curve.get_point_position(p) + movement * speed_factor)
		else:
			var segment_offset_end = segments[p - 1].position - segments[p - 1].transform.basis.y * segments[p - 1].get_child(0).shape.height / 2
			# Update the curve point in a similar manner for the end segment
			var movement_end = segment_offset_end - curve.get_point_position(p)
			curve.set_point_position(p, curve.get_point_position(p) + movement_end * speed_factor)

	# Optional: Handle player attachment, using the same approach to adjust speed
	if player_attached:
		var player_position = player.position
		var rope_position = segments[number_of_segments - 1].position  # end point of the rope
		# Smoothly move the player along the rope without altering the rope's geometry
		player_position = lerp(player_position, rope_position, speed_factor * _delta)
		player.position = player_position

	




	









		


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "player":
		body.can_swing = true
