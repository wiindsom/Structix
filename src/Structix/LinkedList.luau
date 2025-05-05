--!strict
type Node<T> = {value: T, next: Node<T>?, previous: Node<T>?}
export type LinkedListType<T> = {
	getLinkedList: (self: LinkedListType<T>) -> {T};
	size: (self: LinkedListType<T>) -> number;
	copy: (self: LinkedListType<T>) -> LinkedListType<T>;
	clear: (self: LinkedListType<T>) -> ();
	insertFirst: (self: LinkedListType<T>, value: T) -> ();
	insertLast: (self: LinkedListType<T>, value: T) -> ();
	removeFirst: (self: LinkedListType<T>) -> T?;
	removeLast: (self: LinkedListType<T>) -> T?;
	peekFirst: (self: LinkedListType<T>) -> T?;
	peekLast: (self: LinkedListType<T>) -> T?;
	contains: (self: LinkedListType<T>, value: T) -> boolean;
	insertAt: (self: LinkedListType<T>, index: number, value: T) -> ();
	removeAt: (self: LinkedListType<T>, index: number) -> T?;
	get: (self: LinkedListType<T>, index: number) -> T?;
	set: (self: LinkedListType<T>, index: number, value: T) -> ();
	reverse: (self: LinkedListType<T>) -> ();
	map: <U>(self: LinkedListType<T>, callback: (index: number, value: T) -> U) -> {U};
	filter: (self: LinkedListType<T>, callback: (index: number, value: T) -> boolean) -> LinkedListType<T>;
	forEach: (self: LinkedListType<T>, callback: (index: number, value: T) -> ()) -> ();
}
type InternalLinkedList<T> = LinkedListType<T> & {
	_first: Node<T>?;
	_last: Node<T>?;
	_size: number;
	
	_isEmpty: (self: InternalLinkedList<T>) -> boolean;
}
type LinkedList<T = {}> = T & {
	[string]: any;
}

------------------------------------------------------------------------------

local LinkedList = {} :: LinkedList<{
	new: <T>() -> LinkedListType<T>;
}>
LinkedList["__index"] = LinkedList
LinkedList["__eq"] = function<T>(self: InternalLinkedList<T>, other: InternalLinkedList<T>): boolean
	if rawequal(self, other) then return true end
	if self:size() ~= other:size() then return false end
	local nodeA = self._first
	local nodeB = other._first
	while nodeA and nodeB do
		if nodeA.value ~= nodeB.value then
			return false
		end
		nodeA = nodeA.next
		nodeB = nodeB.next
	end
	return nodeA == nil and nodeB == nil
end
LinkedList["__tostring"] = function<T>(self: InternalLinkedList<T>): string
	local elements = {}
	local current = self._first
	while current do
		table.insert(elements, tostring(current.value))
		current = current.next
	end
	return "(Front -> Back): ["..table.concat(elements, ", ").."]"
end

function LinkedList._isEmpty<T>(self: InternalLinkedList<T>): boolean
	return self._size == 0
end

function LinkedList.new<T>(): LinkedListType<T>
	local self = {
		_size = 0;
	} :: InternalLinkedList<T>
	setmetatable(self, LinkedList)
	return self
end

function LinkedList.getLinkedList<T>(self: InternalLinkedList<T>): {T}
	local result = table.create(self._size)
	local current = self._first
	while current do
		table.insert(result, current.value)
		current = current.next
	end
	return result
end

function LinkedList.size<T>(self: InternalLinkedList<T>): number
	return self._size
end

function LinkedList.copy<T>(self: InternalLinkedList<T>): LinkedListType<T>
	if self:_isEmpty() then error("Cannot copy from empty LinkedList.") end
	local copy = LinkedList.new() :: InternalLinkedList<T>
	local current = self._first
	while current do
		copy:insertLast(current.value)
		current = current.next
	end
	return copy
end

function LinkedList.clear<T>(self: InternalLinkedList<T>)
	self._first = nil
	self._last = nil
	self._size = 0
end

function LinkedList.insertFirst<T>(self: InternalLinkedList<T>, value: T)
	local newNode: Node<T> = {value = value, next = nil, previous = nil}
	if self:_isEmpty() then
		self._first = newNode
		self._last = newNode
	else
		newNode.next = self._first
		if self._first then
			self._first.previous = newNode
		end
		self._first = newNode
	end
	self._size += 1
end

function LinkedList.insertLast<T>(self: InternalLinkedList<T>, value: T)
	local newNode: Node<T> = {value = value, next = nil, previous = nil}
	if self:_isEmpty() then
		self._first = newNode
		self._last = newNode
	else
		newNode.previous = self._last
		if self._last then
			self._last.next = newNode
		end
		self._last = newNode
	end
	self._size += 1
end

function LinkedList.removeFirst<T>(self: InternalLinkedList<T>): T?
	if self:_isEmpty() then return nil end
	local firstNode = self._first
	if not firstNode then return nil end
	self._first = firstNode.next
	if self._first then
		self._first.previous = nil
	else
		self._last = nil
	end
	self._size -= 1
	return firstNode.value
end

function LinkedList.removeLast<T>(self: InternalLinkedList<T>): T?
	if self:_isEmpty() then return nil end
	local lastNode = self._last
	if not lastNode then return nil end
	self._last = lastNode.previous
	if self._last then
		self._last.next = nil
	else
		self._first = nil
	end
	self._size -= 1
	return lastNode.value
end

function LinkedList.peekFirst<T>(self: InternalLinkedList<T>): T?
	if self:_isEmpty() then return nil end
	return self._first and self._first.value or nil
end

function LinkedList.peekLast<T>(self: InternalLinkedList<T>): T?
	if self:_isEmpty() then return nil end
	return self._last and self._last.value or nil
end

function LinkedList.contains<T>(self: InternalLinkedList<T>, value: T): boolean
	local current = self._first
	while current do
		if current.value == value then
			return true
		end
		current = current.next
	end
	return false
end

function LinkedList.insertAt<T>(self: InternalLinkedList<T>, index: number, value: T)
	if index < 0 or index > self._size then
		error(`Index {index} out of bounds`)
	end
	
	if index == 0 then
		self:insertFirst(value)
		return
	elseif index == self._size then
		self:insertLast(value)
		return
	end
	
	local current = self._first
	for i = 0, index - 1 do
		current = current and current.next or nil
	end
	
	if current then
		local newNode: Node<T> = { value = value, next = current, previous = current.previous }
		if current.previous then
			current.previous.next = newNode
		end
		current.previous = newNode
		if index == 0 then
			self._first = newNode
		end
	end
	self._size += 1
end

function LinkedList.removeAt<T>(self: InternalLinkedList<T>, index: number): T?
	if index < 0 or index >= self._size then
		error(`Index {index} out of bounds`)
	end
	
	local current = self._first
	for i = 0, index - 1 do
		current = current and current.next or nil
	end
	
	if not current then return nil end
	
	local prevNode = current.previous
	local nextNode = current.next
	
	if prevNode then
		prevNode.next = nextNode
	else
		self._first = nextNode
	end
	
	if nextNode then
		nextNode.previous = prevNode
	else
		self._last = prevNode
	end
	
	self._size -= 1
	return current.value
end


function LinkedList.get<T>(self: InternalLinkedList<T>, index: number): T?
	if index < 0 or index >= self._size then
		return nil
	end
	
	local current = self._first
	for i = 0, index - 1 do
		current = current and current.next or nil
	end
	
	return current and current.value or nil
end

function LinkedList.set<T>(self: InternalLinkedList<T>, index: number, value: T)
	if index < 0 or index >= self._size then
		error(`Index {index} out of bounds`)
	end
	
	local current = self._first
	for i = 0, index - 1 do
		current = current and current.next or nil
	end
	
	if current then
		current.value = value
	end
end

function LinkedList.reverse<T>(self: InternalLinkedList<T>)
	local current = self._first
	local prev = nil
	
	self._last = self._first
	
	while current do
		local Next = current.next
		current.next = prev
		current.previous = Next
		prev = current
		current = Next
	end
	
	self._first = prev
end

function LinkedList.map<T, U>(self: InternalLinkedList<T>, callback: (index: number, value: T) -> U): {U}
	local result = table.create(self._size)
	local current = self._first
	local index = 0
	while current do
		result[index + 1] = callback(index, current.value)
		current = current.next
		index += 1
	end
	return result
end

function LinkedList.filter<T>(self: InternalLinkedList<T>, callback: (index: number, value: T) -> boolean): LinkedListType<T>
	local filtered = LinkedList.new() :: InternalLinkedList<T>
	local current = self._first
	local index = 0
	while current do
		if callback(index, current.value) then
			filtered:insertLast(current.value)
		end
		current = current.next
		index += 1
	end
	return filtered
end

function LinkedList.forEach<T>(self: InternalLinkedList<T>, callback: (index: number, value: T) -> ())
	local current = self._first
	local index = 0
	while current do
		callback(index, current.value)
		current = current.next
		index += 1
	end
end

return LinkedList
