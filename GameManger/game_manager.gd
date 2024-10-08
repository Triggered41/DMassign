extends Node2D

@export var pool: CombatantsPool
@onready var control: Control = $Control

var player_team : Array[Combatant]
var enemy_team : Array[Combatant]

var all_combs : Array[Combatant]
var current_turn := 0

func _ready() -> void:
	pool = CombatantsPool.new()
	for i in pool.POOL_SIZE:
		var c = Combatant.new()
		c.name = char('A'.to_ascii_buffer()[0] + i)
		pool.pool.append(c)
	randomize()
	pool.init()
	
	var buttons = control.get_children() as Array[Button]
	for i in buttons.size():
		buttons[i].button_down.connect(_on_enemy_select.bind(i))
	
	player_team = pool.get_team(Combatant.PLAYER_TEAM)
	enemy_team = pool.get_team(Combatant.ENEMY_TEAM)
	
	print("Player team: ", player_team.map(func(x): return x.name))
	print("Enemy team: ", enemy_team.map(func(x): return x.name))
	
	all_combs = player_team + enemy_team
	
	for i in pool.TEAM_SIZE:
		player_team[i].initiative += randi_range(-3, 3)
		enemy_team[i].initiative += randi_range(-3, 3)
		
	all_combs.sort_custom(func (x, y): return x.initiative > y.initiative)
	
	#print("Init Before: ", all_combs.map(func(x: Combatant):return x.initiative))
	print("\nRound Start\n")
	start_round()
	#print("Init Before: ", all_combs.map(func(x:Combatant):return x.initiative))


func start_round():
	var is_npc_turn := true
	while is_npc_turn:
		is_npc_turn = start_turn()
	

func start_turn() -> bool:
	if current_turn >= all_combs.size():
		print("\nRound End!\n")
		return false
	var init_count := 0
	var current_initiative := all_combs[current_turn].initiative
	
	while current_turn+init_count < all_combs.size() and current_initiative == all_combs[current_turn+init_count].initiative:
		init_count += 1
	init_count -= 1
	
	var pick := current_turn + randi_range(0, init_count)
	var curr := all_combs[pick]
	if curr.team == Combatant.ENEMY_TEAM:
		print("Enemy turn")
		curr.attack_t(player_team.pick_random())
		swap(current_turn, pick)
		init_count = 0
		current_turn += 1
		
		if current_turn+init_count >= all_combs.size(): return false
		current_initiative = all_combs[current_turn].initiative
		return true
	else:
		start_player_turn()
		return false

func start_player_turn():
	pass
	
func _on_enemy_select(index: int) -> void:
	if current_turn >= all_combs.size():
		print("\nRound End!\n")
		return
	print("Player turn")
	all_combs[current_turn].attack_t(enemy_team[index])
	current_turn += 1
	start_round()

func swap(a: int, b: int) -> void:
	if (a != b): print("Swapped")
	var temp = all_combs[a]
	all_combs[a] = all_combs[b]
	all_combs[b] = temp

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
