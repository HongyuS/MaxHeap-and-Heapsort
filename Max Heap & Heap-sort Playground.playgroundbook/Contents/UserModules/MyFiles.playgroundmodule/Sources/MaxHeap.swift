//
//  MaxHeap.swift
//
//  Copyright © 2021 Hongyu Shi. All rights reserved.
//

public struct MaxHeap<T> where T: Comparable {
    
    /// The array that stores the heap's nodes.
    public var nodes = [T]() {
        didSet {
            if !nodes.isEmpty {
                tree = Tree(array: nodes)
            }
        }
    }
    
    public var tree: Tree<T>?
    
    /// Creates an empty max-heap.
    public init() {}
    
    /// Initialize from an array unheapified.
    public init(array: [T]) {
        nodes = array
        heapify()
    }
    
    /// Resets the heap from an array.
    ///
    /// **Note:** Must be heapified before doing anything else.
    public mutating func reset(from array: [T]) {
        nodes = array
        // heapify()
    }
    
    /// Configures the max-heap or from an array, in a bottom-up manner.
    /// ## Complexity
    /// O(*n*)
    private mutating func heapify() {
        for i in stride(from: (nodes.count / 2 - 1), through: 0, by: -1) {
            autoShiftDown(from: i)
        }
    }
    
    public var isEmpty: Bool { nodes.isEmpty }
    public var count: Int { nodes.count }
    
    /// Returns the index of the parent of the element at index *i*.
    /// The element at index `0` is the root of the tree and has no parent.
    private func parentIndex(ofIndex i: Int) -> Int? {
        guard i > 0 && i < nodes.count else { return nil }
        return (i - 1) / 2
    }
    
    /// Returns the index of the left child of the element at index *i*.
    /// If there is no left child, this method returns `nil`.
    private func leftChildIndex(ofIndex i: Int) -> Int? {
        guard 2 * i + 1 < nodes.count else { return nil }
        return 2 * i + 1
    }
    
    /// Returns the index of the right child of the element at index *i*.
    /// If there is no right child, this method returns `nil`.
    private func rightChildIndex(ofIndex i: Int) -> Int? {
        guard 2 * i + 2 < nodes.count else { return nil }
        return 2 * i + 2
    }
    
    /// Returns the maximum value in the heap.
    public func peek() -> T? {
        return nodes.first
    }
    
    /// Appends a new value and reorders the heap so that the max-heap property still holds.
    /// ## Complexity
    /// O(log *n*)
    public mutating func insert(_ value: T) {
        nodes.append(value)
        autoShiftUp(nodes.count - 1)
    }
    
    /// Adds a sequence of values to the heap one by one.
    /// For every value added, this method reorders the heap so that the max-heap property still holds.
    /// ## Complexity
    /// O(log *n*)
    public mutating func insert<S: Sequence>(_ sequence: S) where S.Iterator.Element == T {
        for value in sequence {
            insert(value)
        }
    }
    
    /// Removes the root node (maximum value) from the heap.
    /// ## Complexity
    /// O(log *n*)
    @discardableResult public mutating func remove() -> T? {
        guard !nodes.isEmpty else { return nil }
        
        if nodes.count == 1 {
            return nodes.removeLast()
        } else {
            // Use the last node to replace the first one, then fix the heap by shifting this new first node into its proper position.
            let value = nodes[0]
            nodes[0] = nodes.removeLast()
            autoShiftDown(from: 0)
            return value
        }
    }
    
    /// Shift up from a node recursively, until the heap property is restored.
    private mutating func autoShiftUp(_ index: Int) {
        if let p = shiftUp(index) {
            autoShiftUp(p)
        }
    }
    
    /// Shift down from a node recursively, until the heap property is restored.
    private mutating func autoShiftDown(from index: Int) {
        if let head = shiftDown(from: index) { 
            autoShiftDown(from: head)
        }
    }
    
    /// Takes a child node and looks at its parent; if the child is greater than its parent, we exchange them.
    public mutating func shiftUp(_ index: Int) -> Int? {
        guard let p = parentIndex(ofIndex: index) else { return nil }
        if nodes[index] > nodes[p] {
            nodes.swapAt(index, p)
            tree = Tree(array: nodes)
            return p
        } else {
            return nil
        }
    }
    
    /// Looks at a node and makes sure it is not smaller than its childeren; if not, we swap them.
    public mutating func shiftDown(from index: Int) -> Int? {
        var head = index
        if let i = leftChildIndex(ofIndex: index), nodes[i] > nodes[head] {
            head = i
        }
        if let j = rightChildIndex(ofIndex: index), nodes[j] > nodes[head] {
            head = j
        }
        if head == index { return nil }
        
        nodes.swapAt(index, head)
        tree = Tree(array: nodes)
        return head
    }
}

extension MaxHeap: CustomStringConvertible {
    /// String description of a max-heap.
    public var description: String { "\(nodes)" }
}
