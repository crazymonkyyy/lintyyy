#!/usr/bin/dmd
/**
 * mkystd_data_structures_btree - Binary tree implementation with ranges API
 *
 * Implements monkyyy's ranges API with the required optional functions
 */
module mkystd_data_structures_btree;

import mkystd.range;  // Simplified import path

//---
// Types and Constants
//---

/**
 * Node structure for the binary tree
 */
struct TreeNode(T)
{
    T data;
    TreeNode* left;
    TreeNode* right;
    TreeNode* parent; // For easier navigation
}

/**
 * BinaryTree - A binary tree data structure implementing monkyyy's ranges API
 * When used as a range, it performs an in-order traversal (left-root-right)
 */
struct BinaryTree(T)
{
	TreeNode!(T)* _root = null;
	T[] _traversalCache;  // Cached in-order traversal
	size_t _currentIndex = 0;  // Current position in the range
	bool _needsResolve = false;

	// Constructors
	this(T[] initialValues...)
	{
		foreach(value; initialValues)
		{
			insert(value);
		}
		_needsResolve = true;
		updateCache();
	}

	// Helper to update the traversal cache
	void updateCache()
	{
		_traversalCache = getInOrderTraversal(_root);
		_currentIndex = 0;
		_needsResolve = false;
	}

	// Helper for in-order traversal
	T[] getInOrderTraversal(TreeNode!(T)* node)
	{
		T[] result;
		if (node != null)
		{
			result ~= getInOrderTraversal(node.left);
			result ~= node.data;
			result ~= getInOrderTraversal(node.right);
		}
		return result;
	}

	// Insert a value into the tree
	void insertNode(ref TreeNode!(T)* node, T value, TreeNode!(T)* parent = null)
	{
		if (node == null)
		{
			node = new TreeNode!(T);
			node.data = value;
			node.left = null;
			node.right = null;
			node.parent = parent;
		}
		else if (value < node.data)
		{
			insertNode(node.left, value, node);
		}
		else
		{
			insertNode(node.right, value, node);
		}
	}

	void insert(T value)
	{
		insertNode(_root, value);
		_needsResolve = true;
	}

	// Core range functions
	ref T front() @property
	{
		if (empty())
			assert(0, "Accessing empty tree range");

		return _traversalCache[_currentIndex];
	}

	void pop()
	{
		if (empty())
			assert(0, "Popping empty tree range");

		_currentIndex++;

		// If we've exhausted the current cache, mark for resolve
		if (_currentIndex >= _traversalCache.length && countNonRemoved() > 0)
		{
			_needsResolve = true;
		}
	}

	bool empty() @property
	{
		if (_currentIndex >= _traversalCache.length)
		{
			// Update cache if we need to resolve
			if (_needsResolve)
			{
				updateCache();
			}

			// Check if it's still empty after update
			return _currentIndex >= _traversalCache.length;
		}
		return false;
	}

	// Optional functions as specified
	size_t index()
	{
		return _currentIndex;
	}

	size_t length() @property
	{
		if (_needsResolve)
		{
			// Update cache if needed to get accurate count
			updateCache();
		}
		return _traversalCache.length - _currentIndex;
	}

	BinaryTree reverse()
	{
		// For a tree, reverse could mean inverting the tree structure
		// Or just reversing the traversal order (post-order to pre-order, etc.)
		// Here, we'll reverse the cached traversal array
		if (_needsResolve)
		{
			updateCache();
		}

		// Reverse the order of elements in the cached array
		size_t len = _traversalCache.length;
		for(size_t i = 0; i < len / 2; i++)
		{
			T temp = _traversalCache[i];
			_traversalCache[i] = _traversalCache[len - 1 - i];
			_traversalCache[len - 1 - i] = temp;
		}

		// Reset the current index to the beginning
		_currentIndex = 0;
		_needsResolve = true;

		return this;
	}

	void remove()
	{
		// Mark the current element for removal
		// Since we're using a cache, we can mark the current element in the cache
		// This is a simplified implementation - a full implementation would require
		// a more complex approach to handle removal in the actual tree structure
		if (empty())
			assert(0, "Removing from empty tree range");

		// In this implementation, we mark that we need to rebuild the tree without the element
		// by removing it from the cache and setting a flag
		if (_currentIndex < _traversalCache.length)
		{
			// Create a new cache without the current element
			T[] newCache;
			for(size_t i = 0; i < _traversalCache.length; i++)
			{
				if (i != _currentIndex)
				{
					newCache ~= _traversalCache[i];
				}
			}
			_traversalCache = newCache;

			// Don't advance the index since we removed the current element
			_needsResolve = true;
		}
	}

	void append(T value)
	{
		// Insert value into the tree
		insert(value);

		// This will trigger a resolve on next access
		_needsResolve = true;
	}

	void resolve()
	{
		if (!_needsResolve) return;

		// Refresh the cache to reflect all changes
		updateCache();
	}

	// Additional tree-specific methods
	bool contains(T value)
	{
		return search(_root, value) != null;
	}

	TreeNode!(T)* search(TreeNode!(T)* node, T value)
	{
		if (node == null || node.data == value)
			return node;

		if (value < node.data)
			return search(node.left, value);
		else
			return search(node.right, value);
	}

	// Count non-removed elements (simplified implementation)
	size_t countNonRemoved()
	{
		return _traversalCache.length - _currentIndex;
	}

	// Convert to array
	T[] toArray()
	{
		if (_needsResolve)
		{
			updateCache();
		}
		return _traversalCache.dup;
	}

	// Destructor to properly free memory
	~this()
	{
		destroyTree(_root);
	}

	void destroyTree(TreeNode!(T)* node)
	{
		if (node != null)
		{
			destroyTree(node.left);
			destroyTree(node.right);
			destroy(node);
		}
	}
}