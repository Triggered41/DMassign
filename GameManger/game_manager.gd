extends Node2D

@export var pool: CombatantsPool

var player_team : Array[Combatant]
var enemy_team : Array[Combatant]

var all_combs : Array[Combatant]

func _ready() -> void:
	pool.init()
	randomize()
	
	player_team = pool.get_team(Combatant.PLAYER_TEAM)
	enemy_team = pool.get_team(Combatant.ENEMY_TEAM)
	all_combs = player_team + enemy_team
	for i in pool.TEAM_SIZE:
		player_team[i].initiative += randi_range(-3, 3)
		enemy_team[i].initiative += randi_range(-3, 3)
		
	all_combs.sort_custom(func (x, y): return x.initiative > y.initiative)
	
	start_round()

func start_round():
	var current_turn := 0
	var init_count := 0
	var current_initiative := all_combs[0].initiative
	
	while current_turn < all_combs.size():
		while current_turn+init_count < all_combs.size() and current_initiative == all_combs[current_turn+init_count].initiative:
			init_count += 1
		init_count -= 1
		
		var pick := current_turn + randi_range(0, init_count)
		var curr := all_combs[pick]
		if curr.team == Combatant.ENEMY_TEAM:
			curr.attack(player_team.pick_random())
		else:
			pass
		swap(current_turn, pick)
		init_count = 0
		current_turn += 1
		
		if current_turn+init_count >= all_combs.size(): return
		current_initiative = all_combs[current_turn].initiative

func start_turn(current_turn: int) -> void:
	var init_count := 0
	var current_initiative := all_combs[0].initiative
	
	while current_turn+init_count < all_combs.size() and current_initiative == all_combs[current_turn+init_count].initiative:
		init_count += 1
	init_count -= 1
	
	var pick := current_turn + randi_range(0, init_count)
	var curr := all_combs[pick]
	if curr.team == Combatant.ENEMY_TEAM:
		curr.attack(player_team.pick_random())
		swap(current_turn, pick)
		init_count = 0
		current_turn += 1
		
		if current_turn+init_count >= all_combs.size(): return
		current_initiative = all_combs[current_turn].initiative
	else:
		pass

func swap(a: int, b: int) -> void:
	if (a != b): print("Swapped")
	var temp = all_combs[a]
	all_combs[a] = all_combs[b]
	all_combs[b] = temp

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
