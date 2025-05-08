--!strict

export type DequeType<T> = {
	getDeque: (self: DequeType<T>) -> { T },
	size: (self: DequeType<T>) -> number,
	copy: (self: DequeType<T>) -> DequeType<T>,
	clear: (self: DequeType<T>) -> (),
	pushFirst: (self: DequeType<T>, value: T) -> (),
	pushLast: (self: DequeType<T>, value: T) -> (),
	popFirst: (self: DequeType<T>) -> T?,
	popLast: (self: DequeType<T>) -> T?,
	peekFirst: (self: DequeType<T>) -> T?,
	peekLast: (self: DequeType<T>) -> T?,
}
type InternalDeque<T> = DequeType<T> & {
	_first: number,
	_last: number,
	_deque: { [number]: T },

	_isEmpty: (self: InternalDeque<T>) -> boolean,
}
type Deque<T = {}> = T & {
	[string]: any,
}

------------------------------------------------------------------------------
--- @class Deque
--- Deque class
local Deque = {} :: Deque<{
	new: <T>() -> DequeType<T>,
}>
Deque["__index"] = Deque
Deque["__eq"] = function<T>(self: InternalDeque<T>, other: InternalDeque<T>): boolean
	if rawequal(self, other) then
		return true
	end
	if self:size() ~= other:size() then
		return false
	end
	for i = 0, self:size() - 1 do
		local a = self._deque[self._first + i]
		local b = other._deque[other._first + i]
		if a ~= b then
			return false
		end
	end
	return true
end
Deque["__tostring"] = function<T>(self: InternalDeque<T>): string
	local elements = {}
	for i = self._first, self._last do
		table.insert(elements, tostring(self._deque[i]))
	end
	return "(Front -> Back): [" .. table.concat(elements, ", ") .. "]"
end

function Deque._isEmpty<T>(self: InternalDeque<T>): boolean
	return self._first > self._last
end

--[=[
    Creates a new empty Deque instance.

    @within Deque
    @return DequeType<T> -- A new empty deque.
]=]
function Deque.new<T>(): DequeType<T>
	local self = {
		_first = 0,
		_last = -1,
		_deque = {},
	} :: InternalDeque<T>
	setmetatable(self, Deque)
	return self
end

--[=[
    Returns a shallow array copy of the current deque in front-to-back order.

    @within Deque
    @return { T } -- A table containing all elements in deque order.
]=]
function Deque.getDeque<T>(self: InternalDeque<T>): { T }
	local result = table.create(self:size())
	local index = 1
	for i = self._first, self._last do
		result[index] = self._deque[i]
		index += 1
	end
	return result
end

--[=[
    Returns the number of elements in the deque.

    @within Deque
    @return number -- The size of the deque.
]=]
function Deque.size<T>(self: InternalDeque<T>): number
	return self._last - self._first + 1
end

--[=[
    Returns a new deque with the same elements as this one. Throws an error if the deque is empty.

    @within Deque
    @return DequeType<T> -- A copy of the current deque.
]=]
function Deque.copy<T>(self: InternalDeque<T>): DequeType<T>
	if self:_isEmpty() then
		error("Cannot copy from empty Deque.")
	end
	local copy = Deque.new() :: InternalDeque<T>
	for i = self._first, self._last do
		copy._last += 1
		copy._deque[copy._last] = self._deque[i]
	end
	return copy
end

--[=[
    Removes all elements from the deque.

    @within Deque
]=]
function Deque.clear<T>(self: InternalDeque<T>)
	self._first = 0
	self._last = -1
	table.clear(self._deque)
end

--[=[
    Inserts a value at the front of the deque.

    @within Deque
    @param value T -- The value to insert.
]=]
function Deque.pushFirst<T>(self: InternalDeque<T>, value: T)
	self._first -= 1
	self._deque[self._first] = value
end

--[=[
    Inserts a value at the back of the deque.

    @within Deque
    @param value T -- The value to insert.
]=]
function Deque.pushLast<T>(self: InternalDeque<T>, value: T)
	self._last += 1
	self._deque[self._last] = value
end

--[=[
    Removes and returns the value at the front of the deque.

    @within Deque
    @return T? -- The removed value, or nil if the deque is empty.
]=]
function Deque.popFirst<T>(self: InternalDeque<T>): T?
	if self:_isEmpty() then
		return nil
	end
	local value = self._deque[self._first]
	self._deque[self._first] = nil
	self._first += 1
	return value
end

--[=[
    Removes and returns the value at the back of the deque.

    @within Deque
    @return T? -- The removed value, or nil if the deque is empty.
]=]
function Deque.popLast<T>(self: InternalDeque<T>): T?
	if self:_isEmpty() then
		return nil
	end
	local value = self._deque[self._last]
	self._deque[self._last] = nil
	self._last -= 1
	return value
end

--[=[
    Returns the value at the front of the deque without removing it.

    @within Deque
    @return T? -- The front value, or nil if the deque is empty.
]=]
function Deque.peekFirst<T>(self: InternalDeque<T>): T?
	if self:_isEmpty() then
		return nil
	end
	return self._deque[self._first]
end

--[=[
    Returns the value at the back of the deque without removing it.

    @within Deque
    @return T? -- The back value, or nil if the deque is empty.
]=]
function Deque.peekLast<T>(self: InternalDeque<T>): T?
	if self:_isEmpty() then
		return nil
	end
	return self._deque[self._last]
end

return Deque
