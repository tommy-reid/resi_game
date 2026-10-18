class_name Camera extends Camera3D

@export var follow_player: bool = false
@export var player: Player

func _ready() -> void:
	if follow_player:
		var area = $Trigger
		area.top_level = true

func _physics_process(delta: float) -> void:
	if follow_player and player:
		look_at(player.global_position)


func _on_trigger_body_entered(body: Node3D) -> void:
	if body is Player:
		make_current()
		#for camera in get_tree().get_nodes_in_group("camera"):
