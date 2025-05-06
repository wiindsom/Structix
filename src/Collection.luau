--!strict

export type CollectionType<T> = {
	getCollection: (self: CollectionType<T>) -> {T};
	size: (self: CollectionType<T>) -> number;
	copy: (self: CollectionType<T>) -> CollectionType<T>;
	clear: (self: CollectionType<T>) -> ();
	add: (self: CollectionType<T>, value: T) -> ();
	insert: (self: CollectionType<T>, index: number, value: T) -> ();
	remove: (self: CollectionType<T>, index: number) -> T;
	get: (self: CollectionType<T>, index: number) -> T;
	set: (self: CollectionType<T>, index: number, value: T) -> ();
	contains: (self: CollectionType<T>, value: T) -> boolean;
	forEach: (self: CollectionType<T>, callback: (value: T, index: number) -> ()) -> ();
	map: <U>(self: CollectionType<T>, callback: (value: T, index: number) -> U) -> {U};
	filter: (self: CollectionType<T>, predicate: (value: T, index: number) -> boolean) -> CollectionType<T>;
	reverse: (self: CollectionType<T>) -> ();
}
type InternalCollection<T> = CollectionType<T> & {
	_collection: {T};

	_isEmpty: (self: InternalCollection<T>) -> boolean;
}
type Collection<T = {}> = T & {
	[string]: any;
}

------------------------------------------------------------------------------
--- @class Collection
--- Collection class
local Collection = {} :: Collection<{
	new: <T>() -> CollectionType<T>;
}>
Collection["__index"] = Collection
Collection["__eq"] = function<T>(self: InternalCollection<T>, other: InternalCollection<T>): boolean
	if rawequal(self, other) then return true end
	if self:size() ~= other:size() then return false end
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
	return "["..table.concat(parts, ", ").."]"
end

function Collection._isEmpty<T>(self: InternalCollection<T>): boolean
	return #self._collection == 0
end

function Collection.new<T>(): CollectionType<T>
	local self = {
		_collection = {};
	} :: InternalCollection<T>
	setmetatable(self, Collection)
	return self
end

function Collection.getCollection<T>(self: InternalCollection<T>): {T}
	local result = table.create(#self._collection)
	for i, v in self._collection do
		result[i] = v
	end
	return result
end

function Collection.size<T>(self: InternalCollection<T>): number
	return #self._collection
end

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

function Collection.clear<T>(self: InternalCollection<T>)
	table.clear(self._collection)
end

function Collection.add<T>(self: InternalCollection<T>, value: T)
	table.insert(self._collection, value)
end

function Collection.insert<T>(self: InternalCollection<T>, index: number, value: T)
	table.insert(self._collection, index + 1, value)
end

function Collection.remove<T>(self: InternalCollection<T>, index: number): T
	local value = table.remove(self._collection, index + 1)
	if value == nil then
        error("Invalid index in removeAt.")
    end
	return value
end

function Collection.get<T>(self: InternalCollection<T>, index: number): T
	local value = self._collection[index + 1]
	if value == nil then
        error("Invalid index in get.")
    end
	return value
end

function Collection.set<T>(self: InternalCollection<T>, index: number, value: T)
	if index < 0 or index >= #self._collection then
		error("Index out of bounds in set.")
	end
	self._collection[index + 1] = value
end

function Collection.indexOf<T>(self: InternalCollection<T>, value: T): number?
	for i, v in self._collection do
		if v == value then return i - 1 end
	end
	return nil
end

function Collection.contains<T>(self: InternalCollection<T>, value: T): boolean
	return Collection.indexOf(self, value) ~= nil
end

function Collection.forEach<T>(self: InternalCollection<T>, callback: (value: T, index: number) -> ())
	for i, v in self._collection do
		callback(v, i - 1)
	end
end

function Collection.map<T, U>(self: InternalCollection<T>, callback: (value: T, index: number) -> U): CollectionType<U>
	local new = Collection.new() :: InternalCollection<U>
	for i, v in self._collection do
		table.insert(new._collection, callback(v, i - 1))
	end
	return new
end

function Collection.filter<T>(self: InternalCollection<T>, predicate: (value: T, index: number) -> boolean): CollectionType<T>
	local new = Collection.new() :: InternalCollection<T>
	for i, v in self._collection do
		if predicate(v, i - 1) then
			table.insert(new._collection, v)
		end
	end
	return new
end

function Collection.reverse<T>(self: InternalCollection<T>)
	local size = #self._collection
	for i = 1, math.floor(size / 2) do
		self._collection[i], self._collection[size - i + 1] = self._collection[size - i + 1], self._collection[i]
	end
end

return Collection
