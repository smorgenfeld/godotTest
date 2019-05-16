extends Node

onready var road_straight = preload("res://Assets/Terrain/Road_Straight.tscn")
export (NodePath) var player;
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var curCenter;
var curChunks;
var curPos;
var size = 12;
# Called when the node enters the scene tree for the first time.
func _ready():
	curCenter = getCenter();
	curChunks = []
	curPos = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	reGen();

func reGen():
	var newCenter = getCenter()
	#print(newCenter)
	if ((curCenter - newCenter).length() >= 1):
		print("aaaaa")
		#remove old chunks too far away
		for i in curChunks:
			if ((i.pos-newCenter).length() > size / 2):
				curPos.erase(i.pos);
				curChunks.erase(i);
				i.obj.free();
	 	curCenter = newCenter;
		#add new chunks
		for i in range(size):
			for j in range(size):
				generateChunk(Vector2(curCenter.x - (size / 2) as int + i,curCenter.y - (size / 2) as int + j));

func generateChunk(var pos):
	if (!curPos.has(pos)):
		var obj = road_straight.instance();
		add_child(obj);
		obj.global_transform.origin = (Vector3(pos.x * 9.6, 0, pos.y * 9.6));
		curPos.append(pos);
		var out = chunk.new(pos, obj);
		curChunks.append(out);

func getCenter():
	return Vector2((get_node(player).global_transform.origin.x / 9.6) as int,(get_node(player).global_transform.origin.z / 9.6) as int);

class chunk:
	var pos;
	var obj;
	func _init(var p, var o):
		pos = p;
		obj = o;