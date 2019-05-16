extends RigidBody
export var MAX_ENGINE_FORCE = 150.0
export (NodePath) var mesh
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var ss = get_world().direct_space_state
	if Input.is_action_pressed("ui_up"):
		apply_torque_impulse(Vector3(0,0,15))
	elif Input.is_action_pressed("ui_down"):
		apply_torque_impulse(Vector3(0,0,-15))
	
	#align car
	var rad = 0.85;
	var w = ss.intersect_ray(global_transform.origin, global_transform.origin-(Vector3(0, rad, 0)),[self])
	
	#print(to_global(Vector3(0, 0, 0)))
	#print(to_global(Vector3(0, 0, 0))-(Vector3(0, 2, 0)))
	if (w.has("normal") and w.normal != null):
		get_node(mesh).global_transform.basis = align_up(get_node(mesh).global_transform.basis, w.normal)

		if (abs(global_transform.origin.y-w.position.y) < abs(global_transform.origin.y-rad)):
			get_node(mesh).global_transform.origin = global_transform.origin
			get_node(mesh).global_transform.origin.y = w.position.y
			print("g");
		else:
			get_node(mesh).global_transform.origin = global_transform.origin-Vector3(0,rad,0)
			print("f");
	else:
		get_node(mesh).global_transform.basis = align_up(get_node(mesh).global_transform.basis, Vector3(0,1,0))
		get_node(mesh).global_transform.origin = global_transform.origin-Vector3(0,rad,0)
		print("h");
func align_up(node_basis, normal):
    var result = Basis()
    var scale = node_basis.get_scale() # Only if your node might have a scale other than (1,1,1)

    result.x = normal.cross(node_basis.z)
    result.y = normal
    result.z = node_basis.x.cross(normal)

    result = result.orthonormalized()
    result.x *= scale.x #
    result.y *= scale.y #
    result.z *= scale.z #

    return result