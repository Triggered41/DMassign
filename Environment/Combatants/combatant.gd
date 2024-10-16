extends Resource

## Combatant class to represent a combatant

class_name Combatant

@export var name: String ## Name of the combatant
@export var health: int ## Combatants' health
@export var base_initiative: int ## Base Initiative, initiative decides turn, higher intiative -> early turn, In case of draw random combatant will be chosen
@export var initiative: int ## Calculated from base initiative +/- [0, 3]
@export var team: int ## Whether the combatant is in player or enemy team


enum TEAM{ ## Team enum
	PLAYER_TEAM, ## Player team
	ENEMY_TEAM ## Enemy team
}

## initialize health and initiative to random value [br]
## health => [15, 25] [br]
## initiative => [4, 8]
func init() -> void:
	health = randi_range(15, 25)
	base_initiative = randi_range(4, 8)
	roll_initiative()

## Applies random damage in range [1, 10] to target
static func attack(target: Combatant):
	target.health -= randi_range(1, 10)

## Same as attack but is not static and prints attacker and target name with damage inflicted
func attack_t(target: Combatant):
	var a = randi_range(1, 10)
	print(name, " attacked ", target.name, ", Inflicted " ,a, ' damage')
	target.health = clampi(target.health-a, 0, 25)

## Assigns new initiative equal to base_intiative +/- [0, 3]
func roll_initiative():
	initiative = base_initiative + randi_range(-3, 3)

## Print the curret stats of the combatant
func status():
	print("Name: ", name, ", Health: ", health, ', Initiative: ', initiative)
