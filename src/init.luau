--!strict
-- https://github.com/wiindsom/Structix
-- <3 wiindsom

local BinaryTree = require(script.BinaryTree)
local Collection = require(script.Collection)
local Deque = require(script.Deque)
local Heap = require(script.Heap)
local LinkedList = require(script.LinkedList)
local Map = require(script.Map)
local PriorityQueue = require(script.PriorityQueue)
local Queue = require(script.Queue)
local Set = require(script.Set)
local Stack = require(script.Stack)

export type BinaryTreeType<T> = BinaryTree.BinaryTreeType<T>
export type CollectionType<T> = Collection.CollectionType<T>
export type DequeType<T> = Deque.DequeType<T>
export type HeapType<T> = Heap.HeapType<T>
export type LinkedListType<T> = LinkedList.LinkedListType<T>
export type MapType<K, V> = Map.MapType<K, V>
export type PriorityQueueType<T> = PriorityQueue.PriorityQueueType<T>
export type QueueType<T> = Queue.QueueType<T>
export type SetType<T> = Set.SetType<T>
export type StackType<T> = Stack.StackType<T>

return {
	BinaryTree = BinaryTree;
	Collection = Collection;
	Deque = Deque;
	Heap = Heap;
	LinkedList = LinkedList;
	Map = Map;
	PriorityQueue = PriorityQueue;
	Queue = Queue;
	Set = Set;
	Stack = Stack;
}
