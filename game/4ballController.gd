extends RigidBody

export (NodePath) var FLw
export var FLw_drive = false;
export var FLw_steer = true;
export var FLw_trac = 1.0;
export (NodePath) var FRw
export var FRw_drive = false;
export var FRw_steer = true;
export var FRw_trac = 1.0;
export (NodePath) var BLw
export var BLw_drive = true;
export var BLw_steer = false;
export var BLw_trac = 1.0;
export (NodePath) var BRw
export var BRw_drive = true;
export var BRw_steer = false;
export var BRw_trac = 1.0;
export var POW = 50;
export var MAX_STEER_ANGLE = 1.0;
export var Cs = 20000;
export var steer_speed = 1.0

var steer_target = 0.0
var steer_angle = 0.0
var steer_val = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var ss = get_world().direct_space_state
	var dir = 0;
	if Input.is_action_pressed("ui_up"):
		dir = 1;
	elif Input.is_action_pressed("ui_down"):
		dir = -1;
	steer_val = 0.0;
	if Input.is_action_pressed("ui_left"):
		steer_val = 1.0
	elif Input.is_action_pressed("ui_right"):
		steer_val = -1.0
	steer_target = steer_val * MAX_STEER_ANGLE
	if (steer_target < steer_angle):
		steer_angle -= steer_speed * delta
		if (steer_target > steer_angle):
			steer_angle = steer_target
	elif (steer_target > steer_angle):
		steer_angle += steer_speed * delta
		if (steer_target < steer_angle):
			steer_angle = steer_target
	
	doWheel(ss, dir,get_node(BLw),BLw_drive,BLw_steer,BLw_trac,delta,steer_angle);
	doWheel(ss, dir,get_node(BRw),BRw_drive,BRw_steer,BRw_trac,delta,steer_angle);
	doWheel(ss, dir,get_node(FLw),FLw_drive,FLw_steer,FLw_trac,delta,steer_angle);
	doWheel(ss, dir,get_node(FLw),FRw_drive,FRw_steer,FRw_trac,delta,steer_angle);
	#print(get_global_transform().basis.get_euler().x)
	if (abs(get_global_transform().basis.get_euler().x) > 0.3):
		print("fsdddddddddddddddddddddddddddddddddddddddddddd")
		add_torque(Vector3(-sign(get_global_transform().basis.get_euler().x)*750,0,0))
	
func doWheel(var ss, var dir, var node, var canDrive, var canSteer, var trac, var delta,var steer_angle):
	var rad = node.global_transform.basis.get_scale().x*2;
	var eForce = POW;
	if (!canSteer):
		steer_angle = 0
	var wheelHitPos = get_global_transform().origin-(node.global_transform.origin+transform.basis.xform(Vector3(0,rad/2,0)))
	#if (canDrive):
		#print(wheelHitPos)
	var w = ss.intersect_ray(node.global_transform.origin, node.global_transform.origin - transform.basis.xform(Vector3(0,rad*1.3,0)),[node,self])
	if (w.has("normal")):

		var rv = transform.basis.xform_inv(get_angular_velocity().cross(wheelHitPos) + get_linear_velocity())
		rv.x = -rv.x;
		var comp = (rad*1.1 -w.position.distance_to(node.global_transform.origin))/(rad*1.3);
		#print(comp)
		add_force(get_global_transform().basis.y * (2000*comp-rv.y*200),wheelHitPos)
		#print(rv)
		#engine force
		if (canDrive):
			add_force(get_global_transform().basis.x*dir * POW, wheelHitPos)
			#print(wheelHitPos)
		#cornering force (for all wheels)
		if (abs(rv.x) > 0.01):# && abs(rv.z) > 0.01):
			var a = -atan(rv.z/abs(rv.x))-steer_angle*sign(rv.x)
			var maxSlip = 3;
			if (abs(a) > maxSlip):
				a = sign(a)*maxSlip
			#print(a)
			#print(get_global_transform().basis.z * a * Cs)
			add_force(get_global_transform().basis.z * a * Cs * trac*(min(100,rv.length())/100), wheelHitPos)