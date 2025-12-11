#!/usr/bin/dmd
/**
 * mkystd_data_structures_linkedlist - Linked list implementation with ranges API
 *
 * Implements monkyyy's ranges API with the required optional functions
 */
module mkystd_data_structures_linkedlist;

import mkystd.range;  // Simplified import path
import core.memory : GC;

//---
// Types and Constants
//---

/**
 * Node structure for the linked list
 */
struct Node(T)
{
    T data;
    Node* next;
}

/**
 * LinkedList - A singly linked list implementing monkyyy's ranges API
 */
struct LinkedList(T)
{
	Node!(T)* _head = null;
	Node!(T)* _current = null;  // For range iteration
	size_t _size = 0;
	bool _needsResolve = false;

	// Constructors
	this(T[] initialValues...)
	{
		foreach(value; initialValues)
		{
			append(value);
		}
		resetIterator();
	}

	// Helper to reset the iterator to head
	void resetIterator()
	{
		_current = _head;
	}

	// Core range functions
	ref T front() @property
	{
		if (_current == null)
			assert(0, "Accessing empty range");

		return _current.data;
	}

	void pop()
	{
		if (_current == null)
			assert(0, "Popping empty range");

		// For now, just advance the iterator
		_current = _current.next;

		if (_current == null && _size > 0)
			_needsResolve = true;
	}

	bool empty() @property
	{
		return _current == null;
	}

	// Optional functions as specified
	size_t index()
	{
		// Count how many nodes are between head and current to get the index
		if (_head == null || _current == null)
			return 0;

		size_t idx = 0;
		Node!(T)* temp = _head;
		while (temp != _current && temp != null)
		{
			temp = temp.next;
			idx++;
		}
		return idx;
	}

	size_t length() @property
	{
		// If we haven't resolved pending operations, return the apparent size
		if (!_needsResolve)
			return _size;
		else
		{
			// Count actual nodes to get true size
			size_t count = 0;
			Node!(T)* temp = _head;
			while (temp != null)
			{
				count++;
				temp = temp.next;
			}
			return count;
		}
	}

	LinkedList reverse()
	{
		// Reverse the linked list in place
		Node!(T)* prev = null;
		Node!(T)* current = _head;
		Node!(T)* next = null;

		while (current != null)
		{
			next = current.next;  // Store next
			current.next = prev;  // Reverse current node's pointer

			// Move pointers one position ahead
			prev = current;
			current = next;
		}
		_head = prev;

		// Reset the iterator to the new head (which was the old tail)
		resetIterator();
		_needsResolve = true;

		return this;
	}

	void remove()
	{
		// This is tricky with a singly linked list without a reference to the previous node
		// We'll mark the current node and handle it during resolve
		if (_current == null)
			assert(0, "Removing from empty range");

		// For now, just mark that we need to resolve
		_needsResolve = true;
	}

	void append(T value)
	{
		auto newNode = new Node!(T);
		newNode.data = value;
		newNode.next = null;

		if (_head == null)
		{
			_head = newNode;
		}
		else
		{
			// Find the end of the list and add the new node
			Node!(T)* current = _head;
			while (current.next != null)
			{
				current = current.next;
			}
			current.next = newNode;
		}

		_size++;
		_needsResolve = true;

		// If we're appending to an empty list, also update current for iteration
		if (_current == null)
		{
			resetIterator();
		}
	}

	void resolve()
	{
		if (!_needsResolve) return;

		// For now, just reset the flag since our implementation already maintains list integrity
		// This could involve more sophisticated cleanup in a full implementation
		_needsResolve = false;
		resetIterator();
	}

	// Additional LinkedList-specific methods
	void insertAtHead(T value)
	{
		auto newNode = new Node!(T);
		newNode.data = value;
		newNode.next = _head;
		_head = newNode;

		if (_current == null)
		{
			resetIterator();
		}

		_size++;
		_needsResolve = true;
	}

	// Convert to array
	T[] toArray()
	{
		T[] result;
		Node!(T)* current = _head;
		while (current != null)
		{
			result ~= current.data;
			current = current.next;
		}
		return result;
	}

	// Destructor to properly free memory
	~this()
	{
		while (_head != null)
		{
			auto node = _head;
			_head = _head.next;
			destroy(node);
		}
	}
}