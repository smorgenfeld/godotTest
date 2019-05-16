extends RigidBody

export var MAX_ENGINE_FORCE = 150.0
export var MAX_BRAKE_FORCE = 5.0
export var MAX_STEER_ANGLE = 0.35
export var MAX_SPRING_FORCE = 750
export var MAX_SPRING_LENGTH = 1
export var WHEEL_RAD = 0.1
export var WHEEL_X = 1.0;
export var WHEEL_Y = 1.0;

export var steer_speed = 1.0
var WH = 0.3;
var steer_target = 0.0
var steer_angle = 0.0
var throttle_val = 0.0
var steer_val = 0.0
var lastWheelDist = [[Vector3(0,0,0),Vector3(0,0,0)],[Vector3(0,0,0),Vector3(0,0,0)],[Vector3(0,0,0),Vector3(0,0,0)]
	,[Vector3(0,0,0),Vector3(0,0,0)]]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass;

func _physics_process(delta):
	# get space
	var space_state = get_world().direct_space_state
	#do wheel raycasting
	#lastWheelDist[0] = doWheel(space_state, WHEEL_X, WHEEL_Y, delta, lastWheelDist[0])
	#lastWheelDist[1] = doWheel(space_state, -WHEEL_X, WHEEL_Y, delta, lastWheelDist[1])
	#lastWheelDist[2] = doWheel(space_state, WHEEL_X, -WHEEL_Y, delta, lastWheelDist[2])
	#lastWheelDist[3] = doWheel(space_state, -WHEEL_X, -WHEEL_Y, delta, lastWheelDist[3])
	# overrules for keyboard
	throttle_val = 0
	steer_val = 0
	if Input.is_action_pressed("ui_up"):
		throttle_val = 0
	if Input.is_action_pressed("ui_down"):
		throttle_val = -0
	if Input.is_action_pressed("ui_left"):
		steer_val = 0
		apply_torque_impulse(Vector3(0,10,0));
	elif Input.is_action_pressed("ui_right"):
		steer_val = -1.0
		apply_torque_impulse(Vector3(0,-10,0));
	
	apply_impulse(Vector3(-WHEEL_X / 4,0,0),get_global_transform().basis.x*throttle_val * MAX_ENGINE_FORCE * delta)
	##brake = brake_val * MAX_BRAKE_FORCE
	
	steer_target = steer_val * MAX_STEER_ANGLE
	if (steer_target < steer_angle):
		steer_angle -= steer_speed * delta
		if (steer_target > steer_angle):
			steer_angle = steer_target
	elif (steer_target > steer_angle):
		steer_angle += steer_speed * delta
		if (steer_target < steer_angle):
			steer_angle = steer_target

func doWheel(var ss, var wx, var wy, var delta, var last):
	var w = ss.intersect_ray(to_global(Vector3(wx, 0, wy)), to_global(Vector3(wx, -WHEEL_RAD-MAX_SPRING_LENGTH, wy)),[self])
	var d2 = 1;
	if (w.has("position") and w.position != null):
		var dist = w.position.distance_to(to_global(Vector3(wx, 0, wy)))
		var compression = -(dist/(WHEEL_RAD+MAX_SPRING_LENGTH)) + 1
		var relV = to_local((w.position - to_global(Vector3(wx, 0, wy)))- (last[0] - last[1]))/delta
		relV.x = 0;
		relV.z = 0;
		relV.y = min(abs(relV.y), 50) * sign(relV.y);
		print(compression)
		var shockDrag = to_global(relV) * 0.1;
		apply_impulse(Vector3(wx, 0, wy),get_global_transform().basis.y * delta *
		 (MAX_SPRING_FORCE * compression) + relV*0)
		#print(shockDrag)
		return [w.position,to_global(Vector3(wx, 0, wy))];
	return [Vector3(0,0,0),Vector3(0,0,0)];
