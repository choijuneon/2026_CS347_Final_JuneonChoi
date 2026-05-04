extends Node
class_name Stack
 
var _data = []
 
func push(value):
	_data.append(value)
 
func pop():
	if is_empty():
		return null
	return _data.pop_back()
 
func peek():
	if is_empty():
		return null
	return _data[-1]
 
func is_empty() -> bool:
	return _data.size() == 0
 
func size() -> int:
	return _data.size()
 
func clear():
	_data.clear()
