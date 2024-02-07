extends RefCounted
class_name Command

var func_ref : Callable
var permission_level : int
var max_args : int
var min_args : int
var where : int

func _init(f_ref : Callable, perm_lvl : int, mx_args : int, mn_args : int, whr : int):
	func_ref = f_ref
	permission_level = perm_lvl
	max_args = mx_args
	min_args = mn_args
	where = whr
