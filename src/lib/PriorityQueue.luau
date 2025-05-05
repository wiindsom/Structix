--!strict
type PriorityModes = "min" | "max"
export type PriorityQueueType<T> = {
	getPriorityQueue: (self: PriorityQueueType<T>) -> {{value: T, priority: number}};
	size: (self: PriorityQueueType<T>) -> number;
	copy: (self: PriorityQueueType<T>) -> PriorityQueueType<T>;
	clear: (self: PriorityQueueType<T>) -> ();
	enqueue: (self: PriorityQueueType<T>, value: T, priority: number) -> ();
	dequeue: (self: PriorityQueueType<T>) -> T?;
	peek: (self: PriorityQueueType<T>) -> T?;
}

type InternalPriorityQueue<T> = PriorityQueueType<T> & {
	_heap: {{value: T, priority: number}};
	_mode: PriorityModes;
	_comparator: ((a: number, b: number) -> boolean)?;
	_valueType: string?;
	
	_isEmpty: (self: InternalPriorityQueue<T>) -> boolean;
	_compare: (self: InternalPriorityQueue<T>, i: number, j: number) -> boolean;
	_heapifyUp: (self: InternalPriorityQueue<T>, index: number) -> ();
	_heapifyDown: (self: InternalPriorityQueue<T>, index: number) -> ();
}
type PriorityQueue<T = {}> = T & {
	[string]: any;
}

------------------------------------------------------------------------------

local PriorityQueue = {} :: PriorityQueue<{
	new: <T>(mode: PriorityModes?, comparator: ((a: number, b: number) -> boolean)?) -> PriorityQueueType<T>;
}>
PriorityQueue["__index"] = PriorityQueue
PriorityQueue["__eq"] = function<T>(self: InternalPriorityQueue<T>, other: InternalPriorityQueue<T>): boolean
	if rawequal(self, other) then return true end
	if self:size() ~= other:size() then return false end
	for i = 1, #self._heap do
		local a = self._heap[i]
		local b = other._heap[i]
		if a.priority ~= b.priority or a.value ~= b.value then
			return false
		end
	end
	return true
end
PriorityQueue["__tostring"] = function<T>(self: InternalPriorityQueue<T>): string
	local parts = {}
	for _, entry in self._heap do
		table.insert(parts, `({tostring(entry.value)}:{entry.priority})`)
	end
	return "["..table.concat(parts, ", ").."]"
end

function PriorityQueue._isEmpty<T>(self: InternalPriorityQueue<T>): boolean
	return #self._heap == 0
end

function PriorityQueue._compare<T>(self: InternalPriorityQueue<T>, i: number, j: number): boolean
	local a, b = self._heap[i].priority, self._heap[j].priority
	if self._comparator then
		return self._comparator(a, b)
	elseif self._mode == "min" then
		return a < b
	else
		return a > b
	end
end

function PriorityQueue._heapifyUp<T>(self: InternalPriorityQueue<T>, index: number)
	while index > 1 do
		local parent = math.floor(index / 2)
		if self:_compare(index, parent) then
			self._heap[index], self._heap[parent] = self._heap[parent], self._heap[index]
			index = parent
		else
			break
		end
	end
end

function PriorityQueue._heapifyDown<T>(self: InternalPriorityQueue<T>, index: number)
	local size = #self._heap
	while true do
		local left = 2 * index
		local right = left + 1
		local best = index
		
		if left <= size and self:_compare(left, best) then
			best = left
		end
		
		if right <= size and self:_compare(right, best) then
			best = right
		end
		
		if best ~= index then
			self._heap[index], self._heap[best] = self._heap[best], self._heap[index]
			index = best
		else
			break
		end
	end
end

function PriorityQueue.new<T>(mode: PriorityModes?, comparator: ((a: number, b: number) -> boolean)?): PriorityQueueType<T>
	mode = mode or "min"
	if mode ~= "min" and mode ~= "max" then
		error(`Invalid mode: {mode}`)
	end
	
	local self = {
		_heap = {};
		_mode = mode;
		_comparator = comparator;
	} :: InternalPriorityQueue<T>
	setmetatable(self, PriorityQueue)
	return self
end

function PriorityQueue.getPriorityQueue<T>(self: InternalPriorityQueue<T>): {{value: T, priority: number}}
	local copy = table.create(#self._heap)
	for i, item in self._heap do
		copy[i] = { value = item.value, priority = item.priority }
	end
	return copy
end

function PriorityQueue.size<T>(self: InternalPriorityQueue<T>): number
	return #self._heap
end

function PriorityQueue.copy<T>(self: InternalPriorityQueue<T>): PriorityQueueType<T>
	if self:_isEmpty() then error("Cannot copy from empty PriorityQueue.") end
	local newQueue = PriorityQueue.new() :: InternalPriorityQueue<T>
	for i, item in self._heap do
		newQueue._heap[i] = { value = item.value, priority = item.priority }
	end
	return newQueue
end

function PriorityQueue.clear<T>(self: InternalPriorityQueue<T>)
	table.clear(self._heap)
end

function PriorityQueue.enqueue<T>(self: InternalPriorityQueue<T>, value: T, priority: number)
	local valueType = typeof(value)
	if not self._comparator then
		if valueType == "table" then
			error("PriorityQueue does not support tables or arrays as values unless a comparator is provided.")
		end
	end
	if not self._valueType then
		self._valueType = valueType
	elseif self._valueType ~= valueType then
		error(`PriorityQueue expects values of type '{self._valueType}', but got '{valueType}'.`)
	end
	table.insert(self._heap, { value = value, priority = priority })
	self:_heapifyUp(#self._heap)
end

function PriorityQueue.dequeue<T>(self: InternalPriorityQueue<T>): T?
	if self:_isEmpty() then return nil end
	local root = self._heap[1]
	local last = table.remove(self._heap)
	if #self._heap > 0 and last then
		self._heap[1] = last
		self:_heapifyDown(1)
	end
	return root.value
end

function PriorityQueue.peek<T>(self: InternalPriorityQueue<T>): T?
	if self:_isEmpty() then return nil end
	return self._heap[1].value
end

return PriorityQueue
