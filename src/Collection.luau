--!strict

export type CollectionType<T> = {
	getCollection: (self: CollectionType<T>) -> { T },
	size: (self: CollectionType<T>) -> number,
	copy: (self: CollectionType<T>) -> CollectionType<T>,
	clear: (self: CollectionType<T>) -> (),
	add: (self: CollectionType<T>, value: T) -> (),
	insert: (self: CollectionType<T>, index: number, value: T) -> (),
	remove: (self: CollectionType<T>, index: number) -> T,
	get: (self: CollectionType<T>, index: number) -> T,
	set: (self: CollectionType<T>, index: number, value: T) -> (),
	contains: (self: CollectionType<T>, value: T) -> boolean,
	forEach: (self: CollectionType<T>, callback: (value: T, index: number) -> ()) -> (),
	map: <U>(self: CollectionType<T>, callback: (value: T, index: number) -> U) -> { U },
	filter: (self: CollectionType<T>, predicate: (value: T, index: number) -> boolean) -> CollectionType<T>,
	reverse: (self: CollectionType<T>) -> (),
}
type InternalCollection<T> = CollectionType<T> & {
	_collection: { T },

	_isEmpty: (self: InternalCollection<T>) -> boolean,
}
type Collection<T = {}> = T & {
	[string]: any,
}

------------------------------------------------------------------------------
--- @class Collection
--- Collection class
local Collection = {} :: Collection<{
	new: <T>() -> CollectionType<T>,
}>
Collection["__index"] = Collection
Collection["__eq"] = function<T>(self: InternalCollection<T>, other: InternalCollection<T>): boolean
	if rawequal(self, other) then
		return true
	end
	if self:size() ~= other:size() then
		return false
	end
	for i = 1, #self._collection do
		if self._collection[i] ~= other._collection[i] then
			return false
		end
	end
	return true
end
Collection["__tostring"] = function<T>(self: InternalCollection<T>): string
	local parts = {}
	for _, v in self._collection do
		table.insert(parts, tostring(v))
	end
	return "[" .. table.concat(parts, ", ") .. "]"
end

function Collection._isEmpty<T>(self: InternalCollection<T>): boolean
	return #self._collection == 0
end

--[=[
	Creates a new Collection.

	@within Collection
	@return CollectionType<T> -- A new, empty collection.
]=]
function Collection.new<T>(): CollectionType<T>
	local self = {
		_collection = {},
	} :: InternalCollection<T>
	setmetatable(self, Collection)
	return self
end

--[=[
	Returns a shallow array copy of the collection.

	@within Collection
	@return { T } -- A table containing all elements in the collection.
]=]
function Collection.getCollection<T>(self: InternalCollection<T>): { T }
	local result = table.create(#self._collection)
	for i, v in self._collection do
		result[i] = v
	end
	return result
end

--[=[
	Returns the number of elements in the collection.

	@within Collection
	@return number -- The size of the collection.
]=]
function Collection.size<T>(self: InternalCollection<T>): number
	return #self._collection
end

--[=[
	Returns a shallow copy of the current collection. Throws an error if the collection is empty.

	@within Collection
	@return CollectionType<T> -- A duplicate of the collection.
]=]
function Collection.copy<T>(self: InternalCollection<T>): CollectionType<T>
	if self:_isEmpty() then
		error("Cannot copy from empty Collection.")
	end
	local copy = Collection.new() :: InternalCollection<T>
	for i, v in self._collection do
		copy._collection[i] = v
	end
	return copy
end

--[=[
	Removes all elements from the collection.

	@within Collection
]=]
function Collection.clear<T>(self: InternalCollection<T>)
	table.clear(self._collection)
end

--[=[
	Appends a value to the end of the collection.

	@within Collection
	@param value T -- The value to add.
]=]
function Collection.add<T>(self: InternalCollection<T>, value: T)
	table.insert(self._collection, value)
end

--[=[
	Inserts a value at a given index.

	@within Collection
	@param index number -- The index to insert at (0-based).
	@param value T -- The value to insert.
]=]
function Collection.insert<T>(self: InternalCollection<T>, index: number, value: T)
	table.insert(self._collection, index + 1, value)
end

--[=[
	Removes and returns the value at the specified index.

	@within Collection
	@param index number -- The index to remove (0-based).
	@return T -- The value removed from the collection.
]=]
function Collection.remove<T>(self: InternalCollection<T>, index: number): T
	local value = table.remove(self._collection, index + 1)
	if value == nil then
		error("Invalid index in removeAt.")
	end
	return value
end

--[=[
	Retrieves the value at a specific index.

	@within Collection
	@param index number -- The index to retrieve (0-based).
	@return T -- The value at the specified index.
]=]
function Collection.get<T>(self: InternalCollection<T>, index: number): T
	local value = self._collection[index + 1]
	if value == nil then
		error("Invalid index in get.")
	end
	return value
end

--[=[
	Replaces the value at a given index.

	@within Collection
	@param index number -- The index to modify (0-based).
	@param value T -- The new value to set.
]=]
function Collection.set<T>(self: InternalCollection<T>, index: number, value: T)
	if index < 0 or index >= #self._collection then
		error("Index out of bounds in set.")
	end
	self._collection[index + 1] = value
end

--[=[
	Checks whether the collection contains a specific value.

	@within Collection
	@param value T -- The value to check for.
	@return boolean -- True if the value is found, otherwise false.
]=]
function Collection.contains<T>(self: InternalCollection<T>, value: T): boolean
	return Collection.indexOf(self, value) ~= nil
end

--[=[
	Executes a function for each element in the collection.

	@within Collection
	@param callback (value: T, index: number) -> () -- The function to apply to each element.
]=]
function Collection.forEach<T>(self: InternalCollection<T>, callback: (value: T, index: number) -> ())
	for i, v in self._collection do
		callback(v, i - 1)
	end
end

--[=[
	Transforms each element in the collection using the callback.

	@within Collection
	@param callback (value: T, index: number) -> U -- The transformation function.
	@return CollectionType<U> -- A new collection with transformed values.
]=]
function Collection.map<T, U>(self: InternalCollection<T>, callback: (value: T, index: number) -> U): CollectionType<U>
	local new = Collection.new() :: InternalCollection<U>
	for i, v in self._collection do
		table.insert(new._collection, callback(v, i - 1))
	end
	return new
end

--[=[
	Filters the collection based on a predicate function.

	@within Collection
	@param predicate (value: T, index: number) -> boolean -- The filter condition.
	@return CollectionType<T> -- A new collection with values that match the condition.
]=]
function Collection.filter<T>(
	self: InternalCollection<T>,
	predicate: (value: T, index: number) -> boolean
): CollectionType<T>
	local new = Collection.new() :: InternalCollection<T>
	for i, v in self._collection do
		if predicate(v, i - 1) then
			table.insert(new._collection, v)
		end
	end
	return new
end

--[=[
	Reverses the collection in place.

	@within Collection
]=]
function Collection.reverse<T>(self: InternalCollection<T>)
	local size = #self._collection
	for i = 1, math.floor(size / 2) do
		self._collection[i], self._collection[size - i + 1] = self._collection[size - i + 1], self._collection[i]
	end
end

return Collection
