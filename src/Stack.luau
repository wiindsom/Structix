--!strict

export type StackType<T> = {
	getStack: (self: StackType<T>) -> {T};
	size: (self: StackType<T>) -> number;
	copy: (self: StackType<T>) -> StackType<T>;
	clear: (self: StackType<T>) -> ();
	reverse: (self: StackType<T>) -> ();
	peek: (self: StackType<T>) -> T;
	push: (self: StackType<T>, value: T) -> ();
	pop: (self: StackType<T>) -> T?;
}
type InternalStack<T> = StackType<T> & {
	_stack: {T};
	
	_isEmpty: (self: InternalStack<T>) -> boolean;
}
type Stack<T = {}> = T & {
	[string]: any;
}

------------------------------------------------------------------------------

local Stack = {} :: Stack<{
	new: <T>() -> StackType<T>;
}>
Stack["__index"] = Stack
Stack["__eq"] = function<T>(self: InternalStack<T>, other: InternalStack<T>): boolean
	if rawequal(self, other) then return true end
	if self:size() ~= other:size() then return false end
	for i = 1, self:size() do
		if self._stack[i] ~= other._stack[i] then
			return false
		end
	end
	return true
end
Stack["__tostring"] = function<T>(self: InternalStack<T>): string
	local elements = {}
	for i = #self._stack, 1, -1 do
		table.insert(elements, tostring(self._stack[i]))
	end
	return "(Top -> Bottom): ["..table.concat(elements, ", ").."]"
end

function Stack._isEmpty<T>(self: InternalStack<T>): boolean
	return #self._stack == 0
end

function Stack.new<T>(): StackType<T>
	local self = {
		_stack = {};
	} :: InternalStack<T>
	setmetatable(self, Stack)
	return self
end

function Stack.getStack<T>(self: InternalStack<T>): {T}
	local size = self:size()
	local copy = table.create(size)
	for i = size, 1, -1 do
		copy[size - i + 1] = self._stack[i]
	end
	return copy
end

function Stack.size<T>(self: InternalStack<T>): number
	return #self._stack
end

function Stack.copy<T>(self: InternalStack<T>): StackType<T>
	if self:_isEmpty() then
        error("Cannot copy from empty Stack.")
    end
	local copy = Stack.new() :: InternalStack<T>
	copy._stack = table.clone(self._stack)
	return copy
end

function Stack.clear<T>(self: InternalStack<T>)
	table.clear(self._stack)
end

function Stack.reverse<T>(self: InternalStack<T>)
	local n = #self._stack
	for i = 1, math.floor(n / 2) do
		local leftIndex = i
		local rightIndex = n - i + 1
		local leftValue = self._stack[leftIndex]
		local rightValue = self._stack[rightIndex]
		
		self._stack[leftIndex] = rightValue
		self._stack[rightIndex] = leftValue
	end
end

function Stack.peek<T>(self: InternalStack<T>): T
	if self:_isEmpty() then
        error("Cannot peek from empty stack.")
    end
	return self._stack[#self._stack]
end

function Stack.push<T>(self: InternalStack<T>, value: T)
	table.insert(self._stack, value)
end

function Stack.pop<T>(self: InternalStack<T>): T?
	if self:_isEmpty() then
        error("Cannot pop from empty stack.")
    end
	local popped = table.remove(self._stack, #self._stack)
	return popped
end

return Stack
