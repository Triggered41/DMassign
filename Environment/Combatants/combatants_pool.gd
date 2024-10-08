extends Resource

## Combatants pool of size POOL_SIZE
class_name CombatantsPool

@export var POOL_SIZE := 10 ## Total number of combatants
@export var TEAM_SIZE := 4 ## Size of a single team (All team sizes are assumed to be same)

@export var pool: Array[Combatant] ## Array holding the [Combatant] refs

@export var combatants_count := 0 ## Number of available combatants in the pool
@export var picked_spots: Array[int] ## Indexes of the combatants already in team

## Initialize the [member combatants_count] to pool size also init combatants ([method Combatant.init])
func init() -> void:
	combatants_count = pool.size()
	for i in pool:
		i.init()

## Returns an array of size [member team_size] default to [member TEAM_SIZE]
## returns empty arr if available combatant are less than [member team_size]
func get_team(team_side: int, team_size := TEAM_SIZE) -> Array[Combatant]:
	if combatants_count < team_size:
		printerr("Invalid size: Not Enought Combatants in pool")
		return []
	
	var team: Array[Combatant]
	team.resize(TEAM_SIZE)
	for i in team_size:
		team[i] = pick_combatant()
		team[i].team = team_side
	
	return team

## Returns Array of total combatants for the round i.e. both player and enemy team is returned
func get_batch(team_size := TEAM_SIZE) -> Array:
	if combatants_count < team_size*2:
		printerr("Invalid size: Not enough combatants in pool")
	
	return get_team(Combatant.TEAM.PLAYER_TEAM) + get_team(Combatant.TEAM.ENEMY_TEAM)

## Returns a random combatant from the [member pool] and sets the value in pool to [code]null[/code]
func pick_combatant() -> Combatant:
	var combatant: Combatant
	var index: int
	
	while (combatant == null):
		index = randi() % pool.size()
		combatant = pool[index]
		pool[index] = null
	
	picked_spots.append(index)
	combatants_count -= 1
	return combatant

## Re adds the combatant to their respective spot in the pool
func refill_combatants(batch: Array[Combatant]) -> void:
	var i := 0
	for spot in picked_spots:
		pool[spot] = batch[i]
		i += 1
	
	# Assumes that batch contain all combatants
	combatants_count = POOL_SIZE
	picked_spots = []
