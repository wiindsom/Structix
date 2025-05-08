--!strict
type Node<T> = { value: T, left: Node<T>?, right: Node<T>? }
export type BinaryTreeType<T> = {
	getBinaryTree: (self: BinaryTreeType<T>) -> { T },
	size: (self: BinaryTreeType<T>) -> number,
	copy: (self: BinaryTreeType<T>) -> BinaryTreeType<T>,
	clear: (self: BinaryTreeType<T>) -> (),
	insert: (self: BinaryTreeType<T>, value: T) -> (),
	contains: (self: BinaryTreeType<T>, value: T) -> boolean,
	remove: (self: BinaryTreeType<T>, value: T) -> (),
	min: (self: BinaryTreeType<T>) -> T?,
	max: (self: BinaryTreeType<T>) -> T?,
	height: (self: BinaryTreeType<T>) -> number,
	traverseInOrder: (self: BinaryTreeType<T>) -> { T },
	traversePreOrder: (self: BinaryTreeType<T>) -> { T },
	traversePostOrder: (self: BinaryTreeType<T>) -> { T },
}
type InternalBinaryTree<T> = BinaryTreeType<T> & {
	_root: Node<T>?,
	_size: number,

	_isEmpty: (self: InternalBinaryTree<T>) -> boolean,
}
type BinaryTree<T = {}> = T & {
	[string]: any,
}

------------------------------------------------------------------------------
--- @class BinaryTree
--- BinaryTree class
local BinaryTree = {} :: BinaryTree<{
	new: <T>() -> BinaryTreeType<T>,
}>
BinaryTree["__index"] = BinaryTree
BinaryTree["__eq"] = function<T>(self: InternalBinaryTree<T>, other: InternalBinaryTree<T>): boolean
	if rawequal(self, other) then
		return true
	end
	local function areEqual(nodeA: Node<T>?, nodeB: Node<T>?): boolean
		if not nodeA and not nodeB then
			return true
		end
		if not nodeA or not nodeB then
			return false
		end
		if nodeA.value ~= nodeB.value then
			return false
		end
		return areEqual(nodeA.left, nodeB.left) and areEqual(nodeA.right, nodeB.right)
	end
	return areEqual(self._root, other._root)
end
BinaryTree["__tostring"] = function<T>(self: InternalBinaryTree<T>): string
	local elements = {}
	local function inorder(node: Node<T>?)
		if not node then
			return
		end
		inorder(node.left)
		table.insert(elements, tostring(node.value))
		inorder(node.right)
	end
	inorder(self._root)
	return "(InOrder): [" .. table.concat(elements, ", ") .. "]"
end

function BinaryTree._isEmpty<T>(self: InternalBinaryTree<T>): boolean
	return self._size == 0
end

--[=[
    Creates a new empty binary tree.

    @within BinaryTree
    @return BinaryTreeType<T> -- Empty binary tree instance.
]=]
function BinaryTree.new<T>(): BinaryTreeType<T>
	local self = {
		_size = 0,
	} :: InternalBinaryTree<T>
	setmetatable(self, BinaryTree)
	return self
end

--[=[
    Returns the full contents of the binary tree in pre-order (root-left-right) traversal.

    @within BinaryTree
    @return { T } -- An array containing all values in pre-order.
]=]
function BinaryTree.getBinaryTree<T>(self: InternalBinaryTree<T>): { T }
	local result = {}
	local function build(node: Node<T>?)
		if not node then
			return
		end
		table.insert(result, node.value)
		build(node.left)
		build(node.right)
	end
	build(self._root)
	return result
end

--[=[
    Returns the number of elements in the binary tree.

    @within BinaryTree
    @return number -- The number of elements currently in the tree.
]=]
function BinaryTree.size<T>(self: InternalBinaryTree<T>): number
	return self._size
end

--[=[
    Creates a deep copy of the binary tree. Throws an error if the binary tree is empty.

    @within BinaryTree
    @return BinaryTreeType<T> -- A new binary tree containing all elements from the original.
]=]
function BinaryTree.copy<T>(self: InternalBinaryTree<T>): BinaryTreeType<T>
	if self:_isEmpty() then
		error("Cannot copy from empty BinaryTree.")
	end
	local copy = BinaryTree.new() :: InternalBinaryTree<T>
	local function clone(node: Node<T>?)
		if not node then
			return
		end
		copy:insert(node.value)
		clone(node.left)
		clone(node.right)
	end
	clone(self._root)
	return copy
end

--[=[
    Removes all elements from the binary tree.
    
    @within BinaryTree
]=]
function BinaryTree.clear<T>(self: InternalBinaryTree<T>)
	self._root = nil
	self._size = 0
end

--[=[
    Inserts a new value into the binary tree, preserving the binary search tree property.

    @within BinaryTree
    @param value T -- The value to insert into the tree.
]=]
function BinaryTree.insert<T>(self: InternalBinaryTree<T>, value: T)
	local function insertNode(node: Node<T>?, nodeValue: T): Node<T>
		if not node then
			return { value = nodeValue }
		end
		if (nodeValue :: any) < (node.value :: any) then
			node.left = insertNode(node.left, nodeValue)
		else
			node.right = insertNode(node.right, nodeValue)
		end
		return node
	end
	self._root = insertNode(self._root, value)
	self._size += 1
end

--[=[
    Checks whether a value exists in the tree.

    @within BinaryTree
    @param value T -- The value to search for.
    @return boolean -- true if the value exists in the tree, otherwise false.
]=]
function BinaryTree.contains<T>(self: InternalBinaryTree<T>, value: T): boolean
	local function search(node: Node<T>?, nodeValue: T): boolean
		if not node then
			return false
		end
		if nodeValue == node.value then
			return true
		end
		if (nodeValue :: any) < (node.value :: any) then
			return search(node.left, nodeValue)
		else
			return search(node.right, nodeValue)
		end
	end
	return search(self._root, value)
end

--[=[
    Removes a value from the binary tree if it exists.
    Will warn if the value is not in the binary tree.

    @within BinaryTree
    @param value T -- The value to remove from the tree.
]=]
function BinaryTree.remove<T>(self: InternalBinaryTree<T>, value: T)
	local function removeNode(node: Node<T>?, nodeValue: T): (Node<T>?, boolean)
		if not node then
			return nil, false
		end
		if (nodeValue :: any) < (node.value :: any) then
			local newLeft, removed = removeNode(node.left, nodeValue)
			node.left = newLeft
			return node, removed
		elseif (nodeValue :: any) > (node.value :: any) then
			local newRight, removed = removeNode(node.right, nodeValue)
			node.right = newRight
			return node, removed
		else
			if not node.left then
				return node.right, true
			elseif not node.right then
				return node.left, true
			else
				local successor = node.right
				while successor.left do
					successor = successor.left
				end
				node.value = successor.value
				local newRight, _ = removeNode(node.right, successor.value)
				node.right = newRight
				return node, true
			end
		end
	end
	local newRoot, removed = removeNode(self._root, value)
	self._root = newRoot
	if removed then
		self._size -= 1
	else
		warn(`Value {tostring(value)} not found in BinaryTree.`)
	end
end

--[=[
    Returns the smallest value in the binary tree.
    
    @within BinaryTree
    @return T? -- The minimum value, or nil if the tree is empty.
]=]
function BinaryTree.min<T>(self: InternalBinaryTree<T>): T?
	local current = self._root
	if not current then
		return nil
	end
	while current.left do
		current = current.left
	end
	return current.value
end

--[=[
    Returns the largest value in the binary tree.

    @within BinaryTree
    @return T? -- The maximum value, or nil if the tree is empty.
]=]
function BinaryTree.max<T>(self: InternalBinaryTree<T>): T?
	local current = self._root
	if not current then
		return nil
	end
	while current.right do
		current = current.right
	end
	return current.value
end

--[=[
    Calculates the height of the binary tree.

    @within BinaryTree
    @return number -- The height of the tree (max depth). Returns -1 if the tree is empty.
]=]
function BinaryTree.height<T>(self: InternalBinaryTree<T>): number
	local function getHeight(node: Node<T>?): number
		if not node then
			return -1
		end
		return 1 + math.max(getHeight(node.left), getHeight(node.right))
	end
	return getHeight(self._root)
end

--[=[
    Returns an in-order (left-root-right) traversal of the tree.

    @within BinaryTree
    @return { T } -- Array of values in in-order traversal.
]=]
function BinaryTree.traverseInOrder<T>(self: InternalBinaryTree<T>): { T }
	local result = {}
	local function inorder(node: Node<T>?)
		if not node then
			return
		end
		inorder(node.left)
		table.insert(result, node.value)
		inorder(node.right)
	end
	inorder(self._root)
	return result
end

--[=[
    Returns a pre-order (root-left-right) traversal of the tree.

    @within BinaryTree
    @return { T } -- Array of values in pre-order traversal.
]=]
function BinaryTree.traversePreOrder<T>(self: InternalBinaryTree<T>): { T }
	local result = {}
	local function preorder(node: Node<T>?)
		if not node then
			return
		end
		table.insert(result, node.value)
		preorder(node.left)
		preorder(node.right)
	end
	preorder(self._root)
	return result
end

--[=[
    Returns a post-order (left-right-root) traversal of the tree.
    
    @within BinaryTree
    @return { T } -- Array of values in post-order traversal.
]=]
function BinaryTree.traversePostOrder<T>(self: InternalBinaryTree<T>): { T }
	local result = {}
	local function postorder(node: Node<T>?)
		if not node then
			return
		end
		postorder(node.left)
		postorder(node.right)
		table.insert(result, node.value)
	end
	postorder(self._root)
	return result
end

return BinaryTree
