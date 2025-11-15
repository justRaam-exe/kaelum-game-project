extends Camera2D

# Ukuran satu "layar" (area kamera)
@export var room_size := Vector2(16 * 20, 16 * 12) # 320x192
@export var player_path := NodePath("../Player")
#@export var camera_offset_y := 8.0 # geser kamera ke bawah sedikit
@onready var player = get_node(player_path)

var current_room := Vector2.ZERO
var target_pos := Vector2.ZERO

func _ready():
	make_current()
	current_room = Vector2(
		floor(player.global_position.x / room_size.x),
		floor(player.global_position.y / room_size.y)
	)
	target_pos = current_room * room_size + room_size / 2 + Vector2(0, 8.0)
	position = target_pos

func _process(delta):
	var player_room = Vector2(
		floor(player.global_position.x / room_size.x),
		floor(player.global_position.y / room_size.y)
	)

	if player_room != current_room:
		current_room = player_room
		target_pos = current_room * room_size + room_size / 2 + Vector2(0, 10.0)

	position = position.lerp(target_pos, 0.1)
