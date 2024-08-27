extends Node2D

const GRID_SIZE = 10
const CELL_SIZE = 50
const MINE_COUNT = 15

var grid = []
var game_over = false

func _ready():
	randomize()
	initialize_grid()
	place_mines()
	calculate_numbers()
	create_grid_buttons()

func initialize_grid():
	for x in range(GRID_SIZE):
		grid.append([])
		for y in range(GRID_SIZE):
			grid[x].append({
				"is_mine": false,
				"number": 0,
				"revealed": false,
				"flagged": false
			})

func place_mines():
	var mines_placed = 0
	while mines_placed < MINE_COUNT:
		var x = randi() % GRID_SIZE
		var y = randi() % GRID_SIZE
		if not grid[x][y].is_mine:
			grid[x][y].is_mine = true
			mines_placed += 1

func calculate_numbers():
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			if not grid[x][y].is_mine:
				grid[x][y].number = count_adjacent_mines(x, y)

func count_adjacent_mines(x, y):
	var count = 0
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			var nx = x + dx
			var ny = y + dy
			if nx >= 0 and nx < GRID_SIZE and ny >= 0 and ny < GRID_SIZE:
				if grid[nx][ny].is_mine:
					count += 1
	return count

func create_grid_buttons():
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var button = Button.new()
			button.set_position(Vector2(x * CELL_SIZE, y * CELL_SIZE))
			button.set_size(Vector2(CELL_SIZE - 2, CELL_SIZE - 2))
			button.pressed.connect(_on_cell_pressed.bind(y, x))
			button.gui_input.connect(_on_cell_right_click.bind(y, x))
			add_child(button)

func _on_cell_pressed(x, y):
	print(x, y)
	if game_over or grid[x][y].flagged:
		return
	print(grid[x][y])
	reveal_cell(x, y)

func _on_cell_right_click(event, x, y):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		toggle_flag(x, y)

func reveal_cell(x, y):
	if grid[x][y].revealed:
		return
	grid[x][y].revealed = true
	var button = get_cell_button(x, y)
	
	if grid[x][y].is_mine:
		button.text = "💣"
		game_over = true
		print("Game Over!")
	else:
		if grid[x][y].number > 0:
			button.text = str(grid[x][y].number)
		else:
			button.hide()
			# Reveal adjacent cells if it's an empty cell
			for dx in range(-1, 2):
				for dy in range(-1, 2):
					var nx = x + dx
					var ny = y + dy
					if nx >= 0 and nx < GRID_SIZE and ny >= 0 and ny < GRID_SIZE:
						reveal_cell(nx, ny)

func toggle_flag(x, y):
	if not grid[x][y].revealed:
		grid[x][y].flagged = !grid[x][y].flagged
		var button = get_cell_button(x, y)
		button.text = "🚩" if grid[x][y].flagged else ""

func get_cell_button(x, y):
	return get_child(y * GRID_SIZE + x)
