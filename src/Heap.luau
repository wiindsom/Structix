--!strict
type HeapModes = "min" | "max"
export type HeapType<T> = {
	getHeap: (self: HeapType<T>) -> {T};
	size: (self: HeapType<T>) -> number;
	copy: (self: HeapType<T>) -> HeapType<T>;
	clear: (self: HeapType<T>) -> ();
	insert: (self: HeapType<T>, value: T) -> ();
	peek: (self: HeapType<T>) -> T?;
	remove: (self: HeapType<T>) -> T?;
}
type InternalHeap<T> = HeapType<T> & {
	_heap: {T};
	_mode: HeapModes;
	_comparator: ((a: T, b: T) -> boolean)?;
	_valueType: string?;
	
	_isEmpty: (self: InternalHeap<T>) -> boolean;
	_compare: (self: InternalHeap<T>, a: T, b: T) -> boolean;
	_heapifyUp: (self: InternalHeap<T>, index: number) -> ();
	_heapifyDown: (self: InternalHeap<T>, index: number) -> ();
}
type Heap<T = {}> = T & {
	[string]: any;
}

------------------------------------------------------------------------------

local Heap = {} :: Heap<{
	new: <T>(mode: HeapModes?, comparator: ((a: T, b: T) -> boolean)?) -> HeapType<T>;
}>
Heap["__index"] = Heap
Heap["__eq"] = function<T>(self: InternalHeap<T>, other: InternalHeap<T>): boolean
	if rawequal(self, other) then return true end
	if self:size() ~= other:size() then return false end
	for i = 1, #self._heap do
		if self._heap[i] ~= other._heap[i] then
			return false
		end
	end
	return true
end
Heap["__tostring"] = function<T>(self: InternalHeap<T>): string
	local elements = {}
	for i = 1, #self._heap do
		table.insert(elements, tostring(self._heap[i]))
	end
	return "("..table.concat(elements, ", ")..")"
end

function Heap._isEmpty<T>(self: InternalHeap<T>): boolean
	return #self._heap == 0
end

function Heap._compare<T>(self: InternalHeap<T>, a: T, b: T): boolean
	if self._comparator then
		return self._comparator(a, b)
	elseif self._mode == "min" then
		return (a :: any) < (b :: any)
	else
		return (a :: any) > (b :: any)
	end
end

function Heap._heapifyUp<T>(self: InternalHeap<T>, index: number)
	while index > 1 do
		local parent = math.floor(index / 2)
		if self:_compare(self._heap[index], self._heap[parent]) then
			self._heap[index], self._heap[parent] = self._heap[parent], self._heap[index]
			index = parent
		else
			break
		end
	end
end

function Heap._heapifyDown<T>(self: InternalHeap<T>, index: number)
	local size = #self._heap
	while true do
		local left = 2 * index
		local right = left + 1
		local smallestOrLargest = index
		
		if left <= size and self:_compare(self._heap[left], self._heap[smallestOrLargest]) then
			smallestOrLargest = left
		end
		
		if right <= size and self:_compare(self._heap[right], self._heap[smallestOrLargest]) then
			smallestOrLargest = right
		end
		
		if smallestOrLargest ~= index then
			self._heap[index], self._heap[smallestOrLargest] = self._heap[smallestOrLargest], self._heap[index]
			index = smallestOrLargest
		else
			break
		end
	end
end

function Heap.new<T>(mode: HeapModes?, comparator: ((a: T, b: T) -> boolean)?): HeapType<T>
	mode = mode or "min"
	if mode ~= "min" and mode ~= "max" then
		error(`Invalid mode: {mode}. Must be "min" or "max".`)
	end
	
	local self = {
		_heap = {};
		_mode = mode;
		_comparator = comparator;
	} :: InternalHeap<T>
	setmetatable(self, Heap)
	return self
end

function Heap.getHeap<T>(self: InternalHeap<T>): {T}
	local result = table.create(self:size())
	for key, value in self._heap do
		result[key] = value
	end
	return result
end

function Heap.size<T>(self: InternalHeap<T>): number
	return #self._heap
end

function Heap.copy<T>(self: InternalHeap<T>): HeapType<T>
	if self:_isEmpty() then
        error("Cannot copy from empty Heap.")
    end
	local copy = Heap.new(self._mode) :: InternalHeap<T>
	for key, value in self._heap do
		copy._heap[key] = value
	end
	return copy
end

function Heap.clear<T>(self: InternalHeap<T>)
	table.clear(self._heap)
end

function Heap.insert<T>(self: InternalHeap<T>, value: T)
	local valueType = typeof(value)
	if not self._comparator then
		if valueType == "table" then
			error("Heap does not support tables or arrays as values unless a comparator is provided.")
		end
	end
	if not self._valueType then
		self._valueType = valueType
	elseif valueType ~= self._valueType then
		error(`Heap expects values of type '{self._valueType}', but got '{valueType}'.`)
	end
	table.insert(self._heap, value)
	self:_heapifyUp(#self._heap)
end

function Heap.peek<T>(self: InternalHeap<T>): T?
	if self:_isEmpty() then return nil end
	return self._heap[1]
end

function Heap.remove<T>(self: InternalHeap<T>): T?
	if self:_isEmpty() then return nil end
	local root = self._heap[1]
	local last: any = table.remove(self._heap)
	if #self._heap > 0 then
		self._heap[1] = last
		self:_heapifyDown(1)
	end
	return root
end

return Heap
