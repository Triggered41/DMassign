extends Resource
class_name CombatantsPool

@export var POOL_SIZE := 10
@export var TEAM_SIZE := 4

@export var pool: Array[Combatant]
@export var combatants_count := 0

@export var picked_spots: Array[int]

func init() -> void:
	combatants_count = pool.size()
	picked_spots.resize(TEAM_SIZE*2)
	for i in pool:
		i.init()

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

func get_batch(team_size := TEAM_SIZE) -> Array[Array]:
	if combatants_count < team_size*2:
		printerr("Invalid size: Not enough combatants in pool")
	
	return [get_team(Combatant.PLAYER_TEAM), get_team(Combatant.ENEMY_TEAM)]

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

func refill_combatants(batch) -> void:
	var spots_index = 0
	for i in 2:
		for j in TEAM_SIZE:
			pool[picked_spots[spots_index]] = batch[i][j]
			spots_index += 1
