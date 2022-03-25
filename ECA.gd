#!godot4 --headless --script
extends SceneTree


# Elementary Cellular Automata - Gdscript 2.0

var scale = 8
var random_start = false
var grid_width := 1000 / scale
var grid_height := 480 / scale
var rule := 30
var desktop_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)

func _init():
	print(desktop_path)
	var c = ECA.new(grid_width, grid_height, rule, random_start)
	c.generate()
	c.to_png(desktop_path + "/ECA_Rule" + str(rule) + ".png", scale)
	# c.print()
	quit()

class ECA:

	var cells: Array
	var _next_generation: Array
	var ruleset: Array
	var width: int
	var height: int
	var data: Array

	func _init(w: int, h: int, rule: int, random_start: bool=false):
		self.ruleset = int_to_bit_array(rule)
		self.width = w
		self.height = h
		self.cells.resize(w)
		self.cells.fill(0)
		self._next_generation = cells.duplicate()
		self.cells[w / 2] = 1 # initial cell
		if random_start:
			for i in range(w):
				self.cells[i] = randi() % 2
		self.data.resize(h)

	# calculate next line
	func generate_next() -> void:
		for i in range(1, cells.size() - 1):
			var rule = str(cells[i-1]) + str(cells[i]) + str(cells[i+1])
			self._next_generation[i] = self.ruleset[rule.bin_to_int()]
		self.cells = self._next_generation.duplicate()
		
	# convert 8-bit integer to bit array
	func int_to_bit_array(number: int) -> Array:
		var arr: Array = [0,0,0,0,0,0,0,0]
		for i in range(8):
			arr[7 - i] = int((1 << i & number) != 0)
		arr.reverse()
		return arr
	
	# calculate n generation
	func generate():
		self.data[0] = self.cells.duplicate(true)
		for i in range(1, height):
			self.generate_next()
			self.data[i] = self.cells.duplicate(true)

	func print():
		for h in range(data.size()):
			var strrow = ""
			for row in range(data[0].size()):
				if data[h][row] == 0:
					strrow += "  "
				else:
					strrow += "██"
			print(strrow)
	
	func to_png(path: String, scale: int=1):
		var img = Image.new()
		img.create(self.width, self.height, false, Image.FORMAT_RGBA8)
		for x in range(self.data[0].size()):
			for y in range(self.data.size()):
				if self.data[y][x] == 0:
					img.set_pixel(x, y, Color.BLACK)
				else:
					img.set_pixel(x, y, Color.WHITE)
		if !scale == 1:
			img.resize(self.width * scale, self.height * scale, Image.INTERPOLATE_NEAREST)
		img.save_png(path)
		