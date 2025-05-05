--!strict

export type SetType<T> = {
	getSet: (self: SetType<T>) -> {[T]: boolean};
	size: (self: SetType<T>) -> number;
	copy: (self: SetType<T>) -> SetType<T>;
	clear: (self: SetType<T>) -> ();
	isSubsetOf: (self: SetType<T>, otherSet: SetType<T>) -> boolean;
	isSupersetOf: (self: SetType<T>, otherSet: SetType<T>) -> boolean;
	isDisjoint: (self: SetType<T>, otherSet: SetType<T>) -> boolean;
	contains: (self: SetType<T>, value: T) -> boolean;
	add: (self: SetType<T>, value: T) -> ();
	remove: (self: SetType<T>, value: T) -> ();
	removeAt: (self: SetType<T>, index: number) -> T;
	discard: (self: SetType<T>, value: T) -> ();
	pop: (self: SetType<T>) -> T?;
	union: (self: SetType<T>, otherSet: SetType<T>) -> SetType<T>;
	intersection: (self: SetType<T>, otherSet: SetType<T>) -> SetType<T>;
	difference: (self: SetType<T>, otherSet: SetType<T>) -> SetType<T>;
	symmetric_Difference: (self: SetType<T>, otherSet: SetType<T>) -> SetType<T>;
}
type InternalSet<T> = SetType<T> & {
	_set: {[T]: boolean};
	
	_isEmpty: (self: InternalSet<T>) -> boolean;
}
type Set<T = {}> = T & {
	[string]: any;
}

------------------------------------------------------------------------------

local Set = {} :: Set<{
	new: <T>() -> SetType<T>;
}>
Set["__index"] = Set
Set["__eq"] = function<T>(self: InternalSet<T>, other: InternalSet<T>): boolean
	if rawequal(self, other) then return true end
	if self:size() ~= other:size() then return false end
	for key in self._set do
		if not other:contains(key) then
			return false
		end
	end
	return true
end
Set["__tostring"] = function<T>(self: InternalSet<T>): string
	local elements = {}
	for key in self._set do
		table.insert(elements, `"{tostring(key)}"`)
	end
	return "{"..table.concat(elements, ", ").."}"
end

function Set._isEmpty<T>(self: InternalSet<T>): boolean
	return next(self._set) == nil
end

function Set.new<T>(): SetType<T>
	local self = {
		_set = {};
	} :: InternalSet<T>
	setmetatable(self, Set)
	return self
end

function Set.getSet<T>(self: InternalSet<T>): {[T]: boolean}
	local copy = {}
	for key in self._set do
		copy[key] = true
	end
	return copy
end

function Set.size<T>(self: InternalSet<T>): number
	local result = 0
	for _ in self._set do
		result += 1
	end
	return result
end

function Set.copy<T>(self: InternalSet<T>): SetType<T>
	if self:_isEmpty() then error("Cannot copy from empty Set.") end
	local copy = Set.new() :: InternalSet<T>
	copy._set = table.clone(self._set)
	return copy
end

function Set.clear<T>(self: InternalSet<T>)
	table.clear(self._set)
end

function Set.isSubsetOf<T>(self: InternalSet<T>, otherSet: InternalSet<T>): boolean
	for key in self._set do
		if not otherSet:contains(key) then
			return false
		end
	end
	return true
end

function Set.isSupersetOf<T>(self: InternalSet<T>, otherSet: InternalSet<T>): boolean
	for key in otherSet._set do
		if not self:contains(key) then
			return false
		end
	end
	return true
end

function Set.isDisjoint<T>(self: InternalSet<T>, otherSet: InternalSet<T>): boolean
	for key in self._set do
		if otherSet:contains(key) then
			return false
		end
	end
	return true
end

function Set.contains<T>(self: InternalSet<T>, value: T): boolean
	return self._set[value] ~= nil
end

function Set.add<T>(self: InternalSet<T>, value: T)
	if not self:contains(value) then
		self._set[value] = true
	end
end

function Set.remove<T>(self: InternalSet<T>, value: T)
	if self:contains(value) then
		self._set[value] = nil
	else
		error(`Cannot remove value from set: {tostring(value)} does not exist!`)
	end
end

function Set.removeAt<T>(self: InternalSet<T>, index: number): T
	local keys = table.create(self:size())
	local count = 0
	for key in self._set do
		count += 1
		keys[count] = key
	end
	if index < 0 or index >= count then
		error(`Index {index} out of bounds for Set of size {count}!`)
	end
	local actualKey = keys[index + 1]
	if actualKey == nil then
		error("Unexpected nil key at removeAt set method.")
	end
	self._set[actualKey] = nil
	return actualKey
end

function Set.discard<T>(self: InternalSet<T>, value: T)
	if self:contains(value) then
		self._set[value] = nil
	end
end

function Set.pop<T>(self: InternalSet<T>): T?
	if self:_isEmpty() then error("Cannot pop from empty set.") end
	local temporary = {}
	for key in self._set do
		table.insert(temporary, key)
	end
	local rng = math.random(1, #temporary)
	local result = temporary[rng]
	self._set[result] = nil
	return result
end

function Set.union<T>(self: InternalSet<T>, otherSet: InternalSet<T>): SetType<T>
	if self == otherSet then warn("Attempted to unite with self.") end
	local result = Set.new() :: InternalSet<T>
	for key in self._set do
		result._set[key] = true
	end
	for key in otherSet._set do
		result._set[key] = true
	end
	return result
end

function Set.intersection<T>(self: InternalSet<T>, otherSet: InternalSet<T>): SetType<T>
	if self == otherSet then warn("Attempted to intersect with self.") end
	local result = Set.new() :: InternalSet<T>
	for key in self._set do
		if otherSet:contains(key) then
			result._set[key] = true
		end
	end
	return result
end

function Set.difference<T>(self: InternalSet<T>, otherSet: InternalSet<T>): SetType<T>
	if self == otherSet then warn("Attempted to differentiate with self.") end
	local result = Set.new() :: InternalSet<T>
	for key in self._set do
		if not otherSet:contains(key) then
			result._set[key] = true
		end
	end
	return result
end

function Set.symmetric_Difference<T>(self: InternalSet<T>, otherSet: InternalSet<T>): SetType<T>
	if self == otherSet then warn("Attempted to symmetric-difference a set with self.") end
	local result = Set.new() :: InternalSet<T>
	for key in self._set do
		if not otherSet:contains(key) then
			result._set[key] = true
		end
	end
	for key in otherSet._set do
		if not self:contains(key) then
			result._set[key] = true
		end
	end
	return result
end

return Set
