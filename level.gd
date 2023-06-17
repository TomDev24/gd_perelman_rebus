extends Node2D

var cipher = {}
var answerList = []
var word = ''
var rebusNode = false

func generate_nums():
	var nums = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
	
	var divider = ""
	var divisor = ""
	var divider_len = randi() % 3 + 5 # betwen 5-7
	var divisor_len = 10 - divider_len

	for i in range(divider_len):
		var num = nums[randi() % nums.size()]
		nums.erase(num)
		divider += str(num)
	for i in range(divisor_len):
		var num = nums[randi() % nums.size()]
		nums.erase(num)
		divisor += str(num)
	
	return [int(divider), int(divisor)]


# Called when the node enters the scene tree for the first time.
func _ready():
	rebusNode = get_node('Control/ScrollContainer/Rebus')
	answerList = get_node("Control/AnswersContainer").get_children()
	var file = FileAccess.open('res://db.json', FileAccess.READ)
	var content = JSON.parse_string((file.get_as_text()))
	var words = content.keys()
	word = words[randi() % words.size()]
	for i in range(len(word)):
		cipher[str((i + 1) % 10)] = word[i]
	
	var divider_divisor = generate_nums()
	while divider_divisor[0] % divider_divisor[1] != 0:
		divider_divisor = generate_nums()
	print(answerList)
	print(divider_divisor)
	print(word)
	print(cipher)
	divide_cipher(divider_divisor, cipher)

func str_to_word(string, cipher):
	string = str(string)
	var res = ''
	for l in string:
		res += cipher[l]
	return res

func divide_cipher(divider_divisor, cipher):
	var text = '%s                       | %s ' % [str_to_word(divider_divisor[0], cipher), str_to_word(divider_divisor[1], cipher)]
	text +=    '\n                            | %s\n'
	
	var divider = divider_divisor[0]
	var divisor = divider_divisor[1]
	var s_divider = str(divider_divisor[0])
	var s_divisor = str(divider_divisor[1])
	var result = ['0']
	
	var remain_num_index = len(s_divisor)
	var chunk = int( s_divider.substr(0,remain_num_index) )
	var finish = false
	var count = 0
	while int("".join(result)) * divisor != divider:
		if chunk < divisor:
			chunk = int(str(chunk) + s_divider[remain_num_index])
			remain_num_index += 1
			while chunk < divisor:
				result.append('0')
				if remain_num_index >= len(s_divider):
					finish = true
					break
				chunk = int(str(chunk) + s_divider[remain_num_index])
				remain_num_index += 1
		
		if finish:
			break
		var padding = count
		var multiplier = chunk / divisor
		result.append(str(multiplier))
		var padding_offset = len(str(chunk)) - len(str(divisor * multiplier))
		text += (" ".repeat(padding) + str_to_word(chunk, cipher) + '\n')
		text += (" ".repeat(padding + padding_offset) + str_to_word(divisor * multiplier ,cipher) + '\n')
		text += (" ".repeat(padding) + '-----' + '\n')
		padding_offset = len(str(chunk)) - len(str(chunk - divisor * multiplier))
		chunk = chunk - divisor * multiplier
		text += (" ".repeat(padding + padding_offset) + str_to_word(chunk, cipher) + '\n')
		count += padding_offset
	text = text % str_to_word(''.join(result), cipher)
	rebusNode.text = text
	
func finish():
	print('You won')
	get_tree().change_scene_to_file("res://main.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var answer = ''
	for el in answerList:
		answer += el.text
	if answer == word:
		finish()
