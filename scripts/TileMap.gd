extends TileMap

#tetrominoes
var i_0 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)]
var i_90 := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3)]
var i_180 := [Vector2i(3, 1), Vector2i(2, 1), Vector2i(1, 1), Vector2i(0, 1)]
var i_270 := [Vector2i(0, 3), Vector2i(0, 2), Vector2i(0, 1), Vector2i(0, 0)]
var i := [i_0, i_90, i_180, i_270]

var t_0 := [Vector2i(0, 1), Vector2i(-1, 2), Vector2i(-0, 2), Vector2i(1, 2)]
var t_90 := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)]
var t_180 := [Vector2i(1, 2), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var t_270 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
var t := [t_0, t_90, t_180, t_270]

var o_0 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_90 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_180 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_270 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o := [o_0, o_90, o_180, o_270]

var z_0 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)]
var z_90 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)]
var z_180 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)]
var z_270 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)]
var z := [z_0, z_90, z_180, z_270]

var s_0 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 1), Vector2i(0, 1)]
var s_90 := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
var s_180 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 1), Vector2i(0, 1)]
var s_270 := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
var s := [s_0, s_90, s_180, s_270]

var l_0 := [Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2)]
var l_90 := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(1, 2)]
var l_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)]
var l_270 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)]
var l := [l_0, l_90, l_180, l_270]

var j_0 := [Vector2i(0, 1), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2)]
var j_90 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(0, 2)]
var j_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)]
var j_270 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]
var j := [j_0, j_90, j_180, j_270]

var shapes := [i, t, o, z, s, l, j]
var shapes_full := shapes.duplicate()
#grid variables
const COLS : int = 10
const ROWS : int = 20

#movement variables
const directions := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
var steps : Array
const steps_req : int = 50
const start_pos := Vector2i(0,1)
var cur_pos : Vector2i
var speed : float
const ACCEL : float = 0.25

#game piece variables
var player_cor_x
var player
var piece_type
var next_piece_type
var rotation_index : int = 0
var next_rotation_index : int = 0
var active_piece : Array

#game variables
var score : int
const REWARD : int = 100
var game_running : bool

#tilemap variables
var tile_id : int = 0
var piece_atlas : Vector2i
var next_piece_atlas : Vector2i

# layer variabels
var board_layer : int = 0
var active_layer : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()
	$HUD.get_node("StartButton").pressed.connect(new_game)
	
func new_game():
	#reset variabels
	$HUD.get_node("StartButton").release_focus()
	score = 0
	speed = 1.0
	game_running = true
	Global.game_running = game_running
	steps = [0, 0, 0] #0:left, 1:right, 2:down
	rotation_index = randf_range(1,4)
	$HUD.get_node("GameOverLabel").hide()
	#clear everything
	clear_piece()
	clear_panel()
	clear_board()
	
	piece_type = pick_piece()
	piece_atlas = Vector2i(shapes_full.find(piece_type), 0)
	next_piece_type = pick_piece()
	next_piece_atlas = Vector2i(shapes_full.find(next_piece_type), 0)
	create_piece()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# apply downward movement every frame
	if game_running:
		if Input.is_action_just_pressed("q"):
			rotate_piece()
		steps[2] += speed

		# move the piece
		for i in range(steps.size()):
			if steps[i] > steps_req:
				move_piece(directions[i])
				steps[i] = 0

		player = local_to_map($CharacterBody2D.position)
		player_death()
		
func pick_piece():
	var piece
	if not shapes.is_empty():
		shapes.shuffle()
		piece = shapes.pop_front()
	else:
		shapes = shapes_full.duplicate()
		shapes.shuffle()
		piece = shapes.pop_front()
	return piece

func create_piece():
	#reset variables
	steps = [0, 0, 0] #0:left, 1:right, 2:down
	player_cor_x = local_to_map($CharacterBody2D.position).x
	
	active_piece = piece_type[rotation_index]
	
	var off_set = spawn_off_set(rotation_index)
	
	cur_pos = Vector2i(player_cor_x, start_pos.y)

	
	if (player_cor_x > 8 - off_set and active_piece == i[0] or player_cor_x > 8 - off_set and active_piece == i[2] ):
		cur_pos.x =  8 - off_set
	elif (player_cor_x > 10 - off_set ):
		cur_pos.x =  10 - off_set
	elif (player_cor_x < 1 + off_set):
		cur_pos.x = 0 + off_set
		
	draw_piece(active_piece, cur_pos, piece_atlas)
	#show next piece
	draw_piece(next_piece_type[next_rotation_index], Vector2i(15,6), next_piece_atlas)
	
func clear_piece():
	for i in active_piece:
		erase_cell(active_layer, cur_pos + i)
	
func draw_piece(piece, pos, atlas):
	for i in piece:
		set_cell(active_layer, pos + i, tile_id, atlas)
	
func move_piece(dir):
	if can_move(dir):
		clear_piece()
		cur_pos += dir
		draw_piece(active_piece, cur_pos, piece_atlas)
	else: 
		if dir == Vector2i.DOWN:
			land_piece()
			check_rows()
			piece_type = next_piece_type
			piece_atlas = next_piece_atlas
			rotation_index = next_rotation_index
			next_piece_type = pick_piece()
			next_piece_atlas = Vector2i(shapes_full.find(next_piece_type), 0)
			next_rotation_index = randf_range(1, 4)
			clear_panel()
			create_piece()
			check_game_over()
			
func can_move(dir):
	#check if there is space to move
	var cm = true
	for i in active_piece:
		if not is_free(i + cur_pos + dir):
			cm = false
	return cm

func is_free(pos):
	return get_cell_source_id(board_layer, pos) == -1

func land_piece():
	# remove each segment from the active layer and move to board layer
	score += 25
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score)
	for i in active_piece:
		erase_cell(active_layer, cur_pos + i)
		set_cell(board_layer, cur_pos + i, tile_id, piece_atlas)

func clear_panel():
	for i in range(13,20):
		for j in range(4,10):
			erase_cell(active_layer, Vector2i(i,j))

func check_rows():
	var row : int = ROWS
	while row > 0:
		var count = 0
		for i in range(COLS):
			if not is_free(Vector2i(i + 1, row)):
				count += 1
		#if row is full then erase it
		if count == COLS:
			shift_rows(row)
			score += REWARD
			$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score)
			speed += ACCEL
		else: 
			row -= 1
			
func shift_rows(row):
	var atlas
	for i in range(row, 1, -1):
		for j in range(COLS):
			atlas = get_cell_atlas_coords(board_layer, Vector2i( j + 1, i -1 ))
			if atlas == Vector2i(-1, -1):
				erase_cell(board_layer, Vector2i(j + 1, i))
			else:
				set_cell(board_layer, Vector2i(j+1, i), tile_id, atlas)

func clear_board():
	for i in range(ROWS):
		for j in range(COLS):
			erase_cell(board_layer, Vector2i(j+1, i+1))

func check_game_over():
	for i in active_piece:
		
		if not is_free(i + cur_pos):
			land_piece()
			$HUD.get_node("GameOverLabel").show()
			game_running = false
			Global.game_running = game_running
			# Add any additional game over logic here

func spawn_off_set(rotation):
	var off_set = 0
	if (rotation == 1 or rotation == 3):
		for i in active_piece:
			if (off_set < i.x):
				off_set = i.x
	if (rotation == 0 or rotation == 2):
		for i in active_piece:
			if (off_set < i.y):
				off_set = i.y
	return off_set
	
func rotate_piece():
	if can_rotate():
		clear_piece()
		rotation_index = (rotation_index + 1) % 4
		active_piece = piece_type[rotation_index]
		draw_piece(active_piece, cur_pos, piece_atlas)
		
func can_rotate():
	var cr = true
	var temp_rotation_index = (rotation_index + 1) % 4
	for i in piece_type[temp_rotation_index]:
		if not is_free(i + cur_pos):
			cr = false
	return cr

func player_death():
	for i in active_piece:
		var absolute_position = i + cur_pos
		if absolute_position.x == player.x and absolute_position.y == player.y -1 and Global.jumping == false:
			land_piece()
			$HUD.get_node("GameOverLabel").show()
			game_running = false
			Global.game_running = game_running
			# Add any additional game over logic here
