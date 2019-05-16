extends Camera

export var target_distance = 5.0
export (NodePath) var followThisPath;

var follow_this = null;
var last_lookat

func _ready():
	follow_this = get_node(followThisPath);
	last_lookat = follow_this.global_transform.origin

func _physics_process(delta):
	global_transform.origin = global_transform.origin.linear_interpolate(follow_this.global_transform.origin + Vector3(target_distance,target_distance,target_distance), delta * 20.0)

	last_lookat = last_lookat.linear_interpolate(follow_this.global_transform.origin, delta * 20.0)

	look_at(follow_this.global_transform.origin, Vector3(0.0, 1.0, 0.0))
