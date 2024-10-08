extends Resource
class_name Combatant

@export var name: String
@export var health: int
@export var initiative: int
@export var team: int


enum {
	PLAYER_TEAM,
	ENEMY_TEAM
}

static func attack(target: Combatant):
	target.health -= randi_range(1, 10)

func init() -> void:
	health = randi_range(15, 25)
	initiative = randi_range(4, 8)

func attack_t(target: Combatant):
	var a = randi_range(1, 10)
	print(name, " attacked: ", target.name, ", " ,target.health, '-> ', target.health-a)
	target.health -= a
