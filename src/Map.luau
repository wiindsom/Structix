--!strict
type Entry<K, V> = { key: K, value: V }
export type MapType<K, V> = {
	getMap: (self: MapType<K, V>) -> { [K]: V },
	size: (self: MapType<K, V>) -> number,
	copy: (self: MapType<K, V>) -> MapType<K, V>,
	clear: (self: MapType<K, V>) -> (),
	get: (self: MapType<K, V>, key: K) -> V?,
	set: (self: MapType<K, V>, key: K, value: V) -> (),
	has: (self: MapType<K, V>, key: K) -> boolean,
	delete: (self: MapType<K, V>, key: K) -> (),
	keys: (self: MapType<K, V>) -> { K },
	values: (self: MapType<K, V>) -> { V },
	entries: (self: MapType<K, V>) -> { Entry<K, V> },
	filter: (self: MapType<K, V>, callback: (key: K, value: V) -> boolean) -> MapType<K, V>,
	forEach: (self: MapType<K, V>, callback: (key: K, value: V) -> ()) -> (),
}
type InternalMap<K, V> = MapType<K, V> & {
	_map: { [K]: V },

	_isEmpty: (self: InternalMap<K, V>) -> boolean,
}
type Map<T = {}> = T & {
	[string]: any,
}

------------------------------------------------------------------------------
--- @class Map
--- Map class
local Map = {} :: Map<{
	new: <K, V>() -> MapType<K, V>,
}>
Map["__index"] = Map
Map["__eq"] = function<K, V>(self: InternalMap<K, V>, other: InternalMap<K, V>): boolean
	if rawequal(self, other) then
		return true
	end
	if self:size() ~= other:size() then
		return false
	end
	for key, value in self._map do
		if not other:has(key) or other:get(key) ~= value then
			return false
		end
	end
	return true
end
Map["__tostring"] = function<K, V>(self: InternalMap<K, V>): string
	local pairsText = {}
	for key, value in self._map do
		local keyStr = tostring(key)
		local valueStr = tostring(value)
		table.insert(pairsText, `{keyStr} = {valueStr}`)
	end
	return "{ " .. table.concat(pairsText, ", ") .. " }"
end

function Map._isEmpty<K, V>(self: InternalMap<K, V>): boolean
	return next(self._map) == nil
end

--[=[
	Creates a new empty map.

	@within Map
	@return MapType<K, V>
]=]
function Map.new<K, V>(): MapType<K, V>
	local self = {
		_map = {},
	} :: InternalMap<K, V>
	setmetatable(self, Map)
	return self
end

--[=[
	Returns a shallow copy of the internal hash map.

	@within Map
	@return { [K]: V }
]=]
function Map.getMap<K, V>(self: InternalMap<K, V>): { [K]: V }
	local copy = table.clone(self._map)
	return copy
end

--[=[
	Returns the number of entries in the map.

	@within Map
	@return number
]=]
function Map.size<K, V>(self: InternalMap<K, V>): number
	local result = 0
	for _ in self._map do
		result += 1
	end
	return result
end

--[=[
	Creates and returns a deep copy of the map. Throws an error if the map is empty.

	@within Map
	@return MapType<K, V>
]=]
function Map.copy<K, V>(self: InternalMap<K, V>): MapType<K, V>
	if self:_isEmpty() then
		error("Cannot copy from empty Map.")
	end
	local copy = Map.new() :: InternalMap<K, V>
	for key, value in self._map do
		copy._map[key] = value
	end
	return copy
end

--[=[
	Removes all entries from the map.

	@within Map
]=]
function Map.clear<K, V>(self: InternalMap<K, V>)
	table.clear(self._map)
end

--[=[
	Retrieves a value by key.

	@within Map
	@param key K
	@return V?
]=]
function Map.get<K, V>(self: InternalMap<K, V>, key: K): V?
	return self._map[key]
end

--[=[
	Adds or updates a key-value pair in the map.

	@within Map
	@param key K
	@param value V
]=]
function Map.set<K, V>(self: InternalMap<K, V>, key: K, value: V)
	self._map[key] = value
end

--[=[
	Checks if the map contains the given key.

	@within Map
	@param key K
	@return boolean
]=]
function Map.has<K, V>(self: InternalMap<K, V>, key: K): boolean
	return self._map[key] ~= nil
end

--[=[
	Removes a key-value pair by key.

	@within Map
	@param key K
]=]
function Map.delete<K, V>(self: InternalMap<K, V>, key: K)
	if self._map[key] then
		self._map[key] = nil
	end
end

--[=[
	Returns an array of all keys in the map.

	@within Map
	@return { K }
]=]
function Map.keys<K, V>(self: InternalMap<K, V>): { K }
	local key_table = {}
	for key in self._map do
		table.insert(key_table, key)
	end
	return key_table
end

--[=[
	Returns an array of all values in the map.

	@within Map
	@return { V }
]=]
function Map.values<K, V>(self: InternalMap<K, V>): { V }
	local value_table = {}
	for _, value in self._map do
		table.insert(value_table, value)
	end
	return value_table
end

--[=[
	Returns an array of all key-value entries in the map.

	@within Map
	@return { { key: K, value: V } }
]=]
function Map.entries<K, V>(self: InternalMap<K, V>): { Entry<K, V> }
	local entry_table = {}
	for key, value in self._map do
		table.insert(entry_table, { key = key, value = value })
	end
	return entry_table
end

--[=[
	Filters the map using a predicate function, returning a new map with only matching entries.

	@within Map
	@param callback (key: K, value: V) -> boolean
	@return MapType<K, V>
]=]
function Map.filter<K, V>(self: InternalMap<K, V>, callback: (key: K, value: V) -> boolean): MapType<K, V>
	local result = Map.new() :: InternalMap<K, V>
	for key, value in self._map do
		if callback(key, value) then
			result._map[key] = value
		end
	end
	return result
end

--[=[
	Executes a function for each key-value pair in the map.

	@within Map
	@param callback (key: K, value: V) -> ()
]=]
function Map.forEach<K, V>(self: InternalMap<K, V>, callback: (key: K, value: V) -> ())
	for key, value in self._map do
		callback(key, value)
	end
end

return Map
