extends Resource
class_name Combatant

@export var name: String
@export var health: int
@export var initiative: int
@export var team: int

@export var has_attacked = false

enum {
	PLAYER_TEAM,
	ENEMY_TEAM
}

func init() -> void:
	health = randi_range(15, 25)
	initiative = randi_range(4, 8)

func attack(target: Combatant):
	target.health -= randi_range(1, 10)
	has_attacked = true
