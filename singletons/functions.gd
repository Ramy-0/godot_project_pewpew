extends Node

signal pass_bd_line

# db stands for debug -c0nsole- not double penetration
func print2db(string):
	print(string)
	emit_signal("pass_bd_line", string)


# gets the first parent of a sceen that s in a particular group
func get_fst_parent_in(child, group):
	var parent = child.get_parent()
	while not parent.is_in_group(group):
		child = parent
		parent = child.get_parent()
		
		if parent == null:
			break
	return parent
