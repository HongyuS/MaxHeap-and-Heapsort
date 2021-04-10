public struct Heap<T> where T: Comparable {
    
    /// The array that stores the heap's nodes.
    private(set) var nodes = [T]()
    
    ///
    let compare: (T, T) -> Bool
    
    /// Create an empty heap.
    /// Pass in ">" for a max-heap, and "<" for a min-heap.
    public init(sort: @escaping (T, T) -> Bool) {
        compare = sort
    }
    
    /// Creates a heap from an array. The order of the array does not matter.
    /// Pass in ">" for a max-heap, and "<" for a min-heap.
    public init(_ array: [T], sort: @escaping (T, T) -> Bool) {
        compare = sort
        configureHeap(from: array)
    }
    
    /// Configures the heap from an array, in a bottom-up manner.
    /// Performance: This runs pretty much in O(n).
    private mutating func configureHeap(from array: [T]) {
        nodes = array
        for i in stride(from: (nodes.count / 2 - 1), through: 0, by: -1) {
            shiftDown(i)
        }
    }
    
    public var isEmpty: Bool { nodes.isEmpty }
    public var count: Int { nodes.count }
    
    /// Returns the index of the parent of the element at index i.
    /// The element at index 0 is the root of the tree and has no parent.
    func parentIndex(ofIndex i: Int) -> Int {
        return (i - 1) / 2
    }
    
    /// Returns the index of the left child of the element at index i.
    /// Note that this index can be greater than the heap size, in which case there is no left child.
    func leftChildIndex(ofIndex i: Int) -> Int {
        return 2 * i + 1
    }
    
    /// Returns the index of the right child of the element at index i.
    /// Note that this index can be greater than the heap size, in which case there is no right child.
    func rightChildIndex(ofIndex i: Int) -> Int {
        return 2 * i + 2
    }
    
    /// Returns the maximum value in the heap.
    public func peek() -> T? {
        return nodes.first
    }
    
    /**
     * Adds a new value to the heap. This reorders the heap so that the max-heap
     * property still holds. Performance: O(log n).
     */
    public mutating func insert(_ value: T) {
        nodes.append(value)
        shiftUp(nodes.count - 1)
    }
    
    /**
     * Adds a sequence of values to the heap. This reorders the heap so that
     * the max-heap property still holds. Performance: O(log n).
     */
    public mutating func insert<S: Sequence>(_ sequence: S) where S.Iterator.Element == T {
        for value in sequence {
            insert(value)
        }
    }
    
    /// Removes the root node from the heap. For a max-heap, this is the maximum value. Performance: O(log n).
    @discardableResult public mutating func remove() -> T? {
        guard !nodes.isEmpty else { return nil }
        
        if nodes.count == 1 {
            return nodes.removeLast()
        } else {
            // Use the last node to replace the first one, then fix the heap by
            // shifting this new first node into its proper position.
            let value = nodes[0]
            nodes[0] = nodes.removeLast()
            shiftDown(0)
            return value
        }
    }
    
    /// Takes a child node and looks at its parents.
    /// If a parent is not larger than the child, we exchange them.
    private mutating func shiftUp(_ index: Int) {
        var childIndex = index
        let child = nodes[childIndex]
        var parentIndex = self.parentIndex(ofIndex: childIndex)
        
        while childIndex > 0 && compare(child, nodes[parentIndex]) {
            nodes[childIndex] = nodes[parentIndex]
            childIndex = parentIndex
            parentIndex = self.parentIndex(ofIndex: childIndex)
        }
        
        nodes[childIndex] = child
    }
    
    /// Looks at a parent node and makes sure it is still larger than its childeren.
    private mutating func shiftDown(from index: Int, until endIndex: Int) {
        let leftChildIndex = self.leftChildIndex(ofIndex: index)
        let rightChildIndex = leftChildIndex + 1
        
        // Figure out which comes first if we order them by the sort function:
        // the parent, the left child, or the right child. If the parent comes
        // first, we're done. If not, that element is out-of-place and we make
        // it "float down" the tree until the heap property is restored.
        var first = index
        if leftChildIndex < endIndex && compare(nodes[leftChildIndex], nodes[first]) {
            first = leftChildIndex
        }
        if rightChildIndex < endIndex && compare(nodes[leftChildIndex], nodes[first]) {
            first = rightChildIndex
        }
        if first == index { return }
        
        nodes.swapAt(index, first)
        shiftDown(from: first, until: endIndex)
    }
    
    private mutating func shiftDown(_ index: Int) {
        shiftDown(from: index, until: nodes.count)
    }
    
}

extension Heap {
    public struct Node: Comparable, Identifiable, CustomStringConvertible {
        public let id: Int
        let value: T
        
        public static func < (left: Self, right: Self) -> Bool {
            left.value < right.value
        }
        public static func == (left: Self, right: Self) -> Bool {
            left.value == right.value
        }
        
        public var description: String { "\(value)" }
    }
}

extension Heap: CustomStringConvertible {
    public var description: String { "\(nodes)" }
}

