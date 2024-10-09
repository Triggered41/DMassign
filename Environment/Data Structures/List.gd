# Ignore I was testing something
extends Resource
class_name List

class ListNode:
	var next: ListNode
	var data: Variant

var list_start: ListNode
var list_end: ListNode

var count := 0

func add(element: Variant) -> void:
	var node := ListNode.new()
	node.data = element
	
	if count == 0:
		list_start = node
		list_end = node
		count = 1
		return
	
	list_end.next = node
	list_end = node
	count += 1

func remove(index: int) -> void:
	get_element(index-1)

func get_element(index: int) -> Variant:
	var curr := list_start
	for i in index:
		curr = curr.next
	return curr.data
