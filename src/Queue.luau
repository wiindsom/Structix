--!strict

export type QueueType<T> = {
	getQueue: (self: QueueType<T>) -> { T },
	size: (self: QueueType<T>) -> number,
	copy: (self: QueueType<T>) -> QueueType<T>,
	clear: (self: QueueType<T>) -> (),
	get: (self: QueueType<T>, index: number) -> T,
	peek: (self: QueueType<T>) -> T,
	enqueue: (self: QueueType<T>, value: T) -> (),
	dequeue: (self: QueueType<T>) -> T,
}
type InternalQueue<T> = QueueType<T> & {
	_first: number,
	_last: number,
	_queue: { T },

	_isEmpty: (self: InternalQueue<T>) -> boolean,
	_compact: (self: InternalQueue<T>) -> (),
}
type Queue<T = {}> = T & {
	[string]: any,
}

------------------------------------------------------------------------------
---	@class Queue
---	Queue class
local Queue = {} :: Queue<{
	new: <T>() -> QueueType<T>,
}>
Queue["__index"] = Queue
Queue["__eq"] = function<T>(self: InternalQueue<T>, other: InternalQueue<T>): boolean
	if rawequal(self, other) then
		return true
	end
	if self:size() ~= other:size() then
		return false
	end
	for i = 0, self:size() - 1 do
		local selfValue = self._queue[self._first + i]
		local otherValue = other._queue[other._first + i]
		if selfValue ~= otherValue then
			return false
		end
	end
	return true
end
Queue["__tostring"] = function<T>(self: InternalQueue<T>): string
	local elements = {}
	for i = self._first, self._last do
		local value = self._queue[i]
		if value ~= nil then
			table.insert(elements, tostring(value))
		end
	end
	return "(Front -> Back): [" .. table.concat(elements, ", ") .. "]"
end

function Queue._isEmpty<T>(self: InternalQueue<T>): boolean
	return self._first > self._last
end

function Queue._compact<T>(self: InternalQueue<T>)
	local size = self:size()
	if size == 0 then
		table.clear(self._queue)
		self._first = 0
		self._last = -1
		return
	end
	local newQueue = table.create(size)
	for i = 1, size do
		newQueue[i] = self._queue[self._first + i - 1]
	end
	self._queue = newQueue
	self._first = 1
	self._last = size
end

--[=[
	Creates a new empty Queue.

	@within Queue
	@return QueueType<T>
]=]
function Queue.new<T>(): QueueType<T>
	local self = {
		_first = 0,
		_last = -1,
		_queue = {},
	} :: InternalQueue<T>
	setmetatable(self, Queue)
	return self
end

--[=[
	Returns a shallow copy of the internal queue from front to back.

	@within Queue
	@return { T }
]=]
function Queue.getQueue<T>(self: InternalQueue<T>): { T }
	local size = self:size()
	local copy = table.create(size)
	for i = 0, size - 1 do
		copy[i + 1] = self._queue[self._first + i]
	end
	return copy
end

--[=[
	Returns the number of elements currently in the queue.

	@within Queue
	@return number
]=]
function Queue.size<T>(self: InternalQueue<T>): number
	return self._last - self._first + 1
end

--[=[
	Returns a copy of the current queue and its contents. Throws an error if the queue is empty.

	@within Queue
	@return QueueType<T>
]=]
function Queue.copy<T>(self: InternalQueue<T>): QueueType<T>
	if self:_isEmpty() then
		error("Cannot copy from empty Queue.")
	end
	local copy = Queue.new() :: InternalQueue<T>
	copy._queue = table.clone(self._queue)
	return copy
end

--[=[
	Removes all elements from the queue.

	@within Queue
]=]
function Queue.clear<T>(self: InternalQueue<T>)
	self._first = 0
	self._last = -1
	table.clear(self._queue)
end

--[=[
	Returns the value at a given index relative to the front of the queue.

	@within Queue
	@param index number -- Index starting from 0
	@return T
]=]
function Queue.get<T>(self: InternalQueue<T>, index: number): T
	local size = self:size()
	if index < 0 or index >= size then
		error(`Index {index} out of bounds for Queue of size {size}!`)
	end
	return self._queue[self._first + index]
end

--[=[
	Returns the element at the front of the queue without removing it. Throws an error if the queue is empty.

	@within Queue
	@return T -- The element at the front
]=]
function Queue.peek<T>(self: InternalQueue<T>): T
	if self:_isEmpty() then
		error("Cannot peek from empty queue.")
	end
	return self._queue[self._first]
end

--[=[
	Adds an element to the back of the queue.

	@within Queue
	@param value T -- The value to add
]=]
function Queue.enqueue<T>(self: InternalQueue<T>, value: T)
	local valueType = type(value)
	if value == nil or valueType == "function" or valueType == "thread" then
		error(`Cannot enqueue value of type '{valueType}' into queue.`)
	end
	self:_compact()
	self._last += 1
	self._queue[self._last] = value
end

--[=[
	Removes and returns the front element of the queue. Throws an error if the queue is empty.

	@within Queue
	@return T -- The removed element
]=]
function Queue.dequeue<T>(self: InternalQueue<T>): T
	if self:_isEmpty() then
		error("Cannot dequeue from empty queue.")
	end
	local value = self._queue[self._first]
	self._queue[self._first] = nil
	self._first += 1
	self:_compact()
	return value
end

return Queue
