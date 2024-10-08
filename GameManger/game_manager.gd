extends Node2D

signal round_started
signal round_ended

@export var pool: CombatantsPool

@onready var button_holder: Control = $Buttons
@onready var new_round: Button = $NewRound

var player_team : Array[Combatant]
var enemy_team : Array[Combatant]

var all_combs : Array[Combatant]
var current_turn := 0

var is_game_over = false
func _ready() -> void:
	randomize()
	
	round_ended.connect(_on_round_end)
	
	pool = CombatantsPool.new()
	for i in pool.POOL_SIZE:
		var c = Combatant.new()
		c.name = char('A'.to_ascii_buffer()[0] + i)
		pool.pool.append(c)
	pool.init()
	
	var buttons = button_holder.get_children() as Array[Button]
	for i in buttons.size():
		buttons[i].button_down.connect(_on_enemy_select.bind(i))

func start_round():
	print("\nRound Start\n")
	
	player_team = pool.get_team(Combatant.TEAM.PLAYER_TEAM)
	enemy_team = pool.get_team(Combatant.TEAM.ENEMY_TEAM)
	
	if check_game_over() > -1:
		print("End Game")
		update_status()
		button_holder.hide()
		return
		
	for i in pool.TEAM_SIZE:
		player_team[i].initiative += randi_range(-3, 3)
		enemy_team[i].initiative += randi_range(-3, 3)
	
	all_combs = player_team + enemy_team
	all_combs.sort_custom(func (x, y): return x.initiative > y.initiative)

	print("Player team: ", player_team.map(func(x): return x.name))
	print("Enemy team: ", enemy_team.map(func(x): return x.name))
	
	current_turn = 0
	button_holder.show()
	update_status()
	continue_round()
	
	round_started.emit()

func continue_round():
	var is_npc_turn := true
	while is_npc_turn:
		is_npc_turn = start_turn()
	

func start_turn() -> bool:
	if check_game_over() > -1:
		print("End Game")
		update_status()
		button_holder.hide()
		return false
	if current_turn >= all_combs.size():
		round_ended.emit()
		return false
	
	var init_count := get_common_initiatives()
	
	print("\n===== Turn ", current_turn,' ======\n')
	
	var pick := current_turn + randi_range(0, init_count)
	var curr := all_combs[pick]
	print("Pick: ", pick)
	print("Curr: ", all_combs[pick].name, ', ', all_combs[pick].team)
	if curr.team == Combatant.TEAM.ENEMY_TEAM:
		print("Enemy turn ->")
		
		curr.attack_t(pick_target(player_team))
		swap(current_turn, pick)
		update_status()
		
		init_count = 0
		current_turn += 1
		
		if check_game_over() > -1:
			print("End Game")
			button_holder.hide()
			return false
			
		return true
	else:
		print("Player turn ->")
		return false

func pick_target(team: Array[Combatant]):
	var combatants := []
	var pick = randi() % team.size()
	
	combatants.resize(team.size())
	for i in combatants.size():
		combatants[i] = i
		
	while combatants.size() > 1 and team[combatants[pick]].health <= 0:
		combatants.remove_at(pick)
		pick = randi() % combatants.size()
	return team[pick]

func get_common_initiatives() -> int:
	var init_count := 0
	var current_initiative := all_combs[current_turn].initiative
	
	while current_turn+init_count < all_combs.size() and current_initiative == all_combs[current_turn+init_count].initiative:
		init_count += 1
		
	return init_count - 1

func update_status():
	print(' _____________________________________')
	print("| Player team      |      Enemy team  |")
	print('|__________________|__________________|')
	print("| ","   ".join(player_team.map(func(x): return x.name)), "    |  ","   ".join(enemy_team.map(func(x): return x.name)), '   |')
	print("| ","  ".join(player_team.map(func(x): return "%02d"%x.health)), "   |  ","  ".join(enemy_team.map(func(x): return "%02d"%x.health)), '  |')

func _on_enemy_select(index: int) -> void:
	#if current_turn >= all_combs.size():
		#print("\nRound End! PL\n")
		#return
	all_combs[current_turn].attack_t(enemy_team[index])
	current_turn += 1
		
	update_status()
	continue_round()
	
			

func swap(a: int, b: int) -> void:
	var temp = all_combs[a]
	all_combs[a] = all_combs[b]
	all_combs[b] = temp

func _on_new_round_button_up() -> void:
	new_round.hide()
	start_round()

func _on_round_end():
	print("\nRound End!\n")
	button_holder.hide()
	new_round.show()
	pool.refill_combatants(all_combs)

func check_game_over() -> int:
	var player_team_health = 0
	var enemy_team_health = 0
	for i in pool.TEAM_SIZE:
		player_team_health += player_team[i].health
		enemy_team_health += enemy_team[i].health
	if player_team_health <= 0:
		return Combatant.TEAM.PLAYER_TEAM
	if enemy_team_health <= 0:
		return Combatant.TEAM.ENEMY_TEAM
	return -1
