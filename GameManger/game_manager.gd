extends Node2D

signal round_started
signal round_ended
signal game_over(winner)

@export var pool: CombatantsPool

@onready var button_holder: Control = $Buttons
@onready var new_round: Button = $NewRound
@onready var label: Label = $Label

var player_team : Array[Combatant]
var enemy_team : Array[Combatant]

var all_combs : Array[Combatant]
var current_turn := 0

var is_game_over = false
func _ready() -> void:
	randomize()
	
	round_ended.connect(_on_round_end)
	game_over.connect(_on_game_over)
	var buttons = button_holder.get_children() as Array[Button]
	for i in buttons.size():
		buttons[i].button_down.connect(_on_enemy_select.bind(i))
	
	pool = CombatantsPool.new()
	pool.init()
	
	player_team = pool.get_team(Combatant.TEAM.PLAYER_TEAM)
	enemy_team = pool.get_team(Combatant.TEAM.ENEMY_TEAM)
	
	all_combs = player_team + enemy_team
	

func start_round():
	print("\nRound Start\n")
	
	print("Player team: ", player_team.map(func(x): return x.name))
	print("Enemy team: ", enemy_team.map(func(x): return x.name))
	
	all_combs.sort_custom(func (x, y): return x.initiative > y.initiative)
	current_turn = 0
	
	update_status()
	continue_round()
	round_started.emit()
	
	if check_game_over(): return

func continue_round():
	var skip := true
	while skip:
		skip = start_turn()
	

func start_turn() -> bool:
	if current_turn >= all_combs.size():
		round_ended.emit()
		return false
	
	print("\n===== Turn ", current_turn+1,' =====\n')
	
	var init_count := get_common_initiatives()
	var pick := current_turn + randi_range(0, init_count)
	var curr := all_combs[pick]
	swap(current_turn, pick)
	
	if curr.team == Combatant.TEAM.ENEMY_TEAM:
		print("Enemy turn ->")
		
		curr.attack_t(pick_target(player_team))
		
		update_status()
		
		#init_count = 0
		current_turn += 1
		
		if check_game_over(): return false
		return true
	else:
		print("Player turn ->")
		button_holder.show()
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
	print("|__________________|__________________|")

var count := 0
func _on_enemy_select(index: int) -> void:
	all_combs[current_turn].attack_t(enemy_team[index])
	update_status()
	
	current_turn += 1
	continue_round()
	check_game_over()

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
	pool.roll_initiatives(player_team)
	pool.roll_initiatives(enemy_team)
	count = 0

func check_game_over() -> bool:
	var player_team_health = 0
	var enemy_team_health = 0
	for i in pool.TEAM_SIZE:
		player_team_health += player_team[i].health
		enemy_team_health += enemy_team[i].health
	if player_team_health <= 0:
		game_over.emit(Combatant.TEAM.ENEMY_TEAM)
		return true
	if enemy_team_health <= 0:
		game_over.emit(Combatant.TEAM.PLAYER_TEAM)
		return true
	return false

func _on_game_over(winner: int):
	print("\nd===== Game Over =====\n")
	if winner == Combatant.TEAM.PLAYER_TEAM:
		print("\n===== Player team won =====\n")
		label.text = "Player team won"
		label.show()
	else:
		print("\n===== Enemy team won =====\n")
		label.text = "Enemy team won"
		label.show()
	update_status()
	button_holder.hide()
	pool.refill_combatants(all_combs)


func _on_new_game_button_up() -> void:
	get_tree().reload_current_scene()
