//#-hidden-code
//
//  Array+Heapsort.swift
//
//  Copyright © 2021 Hongyu Shi. All rights reserved.
//
//#-end-hidden-code
/*:
 # Beyond Assignment III - Integrate Heapsort into Swift APIs #
 
 *The Swift Programming Language* is designed to be **extensible**. As a result, we can integrate our heapsort algorithm into the standard implementation of array, simply by:
 ```
 extension Array {
     // Implementations here
 }
 ```
 On this page, I will demonstrate how this can be done. 😊
 */
// MARK: - Convenient APIs
/*:
 **Convenient APIs** for sorting an array using the Heapsort algorithm, where the elements conform to the Comparable protocol.
 */
extension Array where Element: Comparable {
/*:
 Sorts the array in place using the *Heapsort* algorithm.

 You can sort any mutable array whose elements conform to the `Comparable` protocol by calling this method. Elements are sorted in ascending order.
 ```
 ascendingArray.heapSort()
 ```
 To sort the elements of your array in descending order, pass the greater-than operator (`>`) to the `heapSort(by:)` method.
 ```
 descendingArray.heapSort(by: >)
 ```
 
 **Complexity**
     
 O(*n* log *n*), where *n* is the length of the array.
 */
    public mutating func heapSort() {
        heapSort(by: <)
    }
    
/*:
 Returns the elements of the array, sorted using the *Heapsort* algorithm.

 You can sort any array whose elements conform to the `Comparable` protocol by calling this method. Elements are sorted in ascending order.
 ```
 let ascendingArray = exampleArray.heapSorted()
 ```
 To sort the elements of your sequence in descending order, pass the greater-than operator (`>`) to the `sorted(by:)` method.
 ```
 let descendingArray = exampleArray.heapSorted(by: >)
 ```
 - returns: A sorted array of the array’s elements.
 
 **Complexity**
     
 O(*n* log *n*), where *n* is the length of the array.
 */
    public func heapSorted() -> Self {
        heapSorted(by: <)
    }
}

// MARK: - General APIs
/*:
 **General APIs** for sorting an array using the Heapsort algorithm
 */
extension Array {
/*:
 Sorts the array in place using the *Heapsort* algorithm, and the given predicate as the comparison between elements.

 When you want to sort a mutable array whose elements don’t conform to the `Comparable` protocol, pass a closure to this method that returns `true` when the first element should be ordered before the second.

 Alternatively, use this method to sort elements that do conform to `Comparable` when you want the sort to be descending instead of ascending. Pass the greater-than operator (`>`) operator as the predicate.
 - parameter predicate: A predicate that returns `true` if its first argument should be ordered before its second argument; otherwise, `false`. Pass in "`<`" to sort in ascending order, or "`>`" to sort in descending order.
 
 **Complexity**
     
 O(*n* log *n*), where *n* is the length of the array.
 */
    public mutating func heapSort(by predicate: @escaping (Element, Element) -> Bool) {
        heapify(by: predicate)
        for i in 0 ..< count {
            swapAt(0, count - 1 - i)
            shiftDown(from: 0, to: count - 1 - i, by: predicate)
        }
    }
    
/*:
 Returns the elements of the array, sorted using the *Heapsort* algorithm and the given predicate as the comparison between elements.

 When you want to sort an array whose elements don’t conform to the `Comparable` protocol, pass a predicate to this method that returns `true` when the first element should be ordered before the second. The elements of the resulting array are ordered according to the given predicate.

 You can also use this method to sort elements that conform to the `Comparable` protocol in descending order. To sort your array in descending order, pass the greater-than operator (`>`) as the predicate.
 - parameter predicate: A predicate that returns `true` if its first argument should be ordered before its second argument; otherwise, `false`. Pass in "`<`" to sort in ascending order, or "`>`" to sort in descending order.
 - returns: A sorted array of the array’s elements.
 
 **Complexity**
     
 O(*n* log *n*), where *n* is the length of the array.
 */
    public func heapSorted(by predicate: @escaping (Element, Element) -> Bool) -> Self {
        var result = self
        result.heapSort(by: predicate)
        return result
    }
}

// MARK: - Methods used in the Heapsort algorithm
extension Array {
    
    /// Configures the heap from an array, in a bottom-up manner.
    /// - parameter predicate: A predicate that returns `true` if its first argument should be ordered before its second argument; otherwise, `false`.
    /// ## Complexity
    /// O(*n*)
    private mutating func heapify(by predicate: @escaping (Element, Element) -> Bool) {
        for i in stride(from: (count / 2 - 1), through: 0, by: -1) {
            shiftDown(from: i, to: count, by: predicate)
        }
    }
    
    /// Returns the index of the parent of the element at index *i*.
    /// The element at index `0` is the root of the tree and has no parent.
    private func parentIndex(ofIndex i: Int) -> Int? {
        guard i > 0 && i < count else { return nil }
        return (i - 1) / 2
    }
    
    /// Returns the index of the left child of the element at index *i*.
    /// If there is no left child, this method returns `nil`.
    private func leftChildIndex(ofIndex i: Int) -> Int? {
        guard 2 * i + 1 < count else { return nil }
        return 2 * i + 1
    }
    
    /// Returns the index of the right child of the element at index *i*.
    /// If there is no right child, this method returns `nil`.
    private func rightChildIndex(ofIndex i: Int) -> Int? {
        guard 2 * i + 2 < count else { return nil }
        return 2 * i + 2
    }
    
    /// Looks at a node and makes sure it is not smaller than its children; if not, we swap them, and check agian (recursively), until the heap property is restored.
    /// - parameter index: The starting index.
    /// - parameter endIndex: The index after the ending index.
    /// - parameter compare: A predicate that returns `true` if its first argument should be ordered before its second argument; otherwise, `false`.
    /// ## Complexity
    /// O(log *n*)
    private mutating func shiftDown(from index: Int, to endIndex: Int, by compare: @escaping (Element, Element) -> Bool) {
        var head = index
        if let i = leftChildIndex(ofIndex: index), i < endIndex &&  compare(self[head], self[i]) {
            head = i
        }
        if let j = rightChildIndex(ofIndex: index), j < endIndex && compare(self[head], self[j]) {
            head = j
        }
        if head == index { return }
        
        swapAt(index, head)
        shiftDown(from: head, to: endIndex, by: compare)
    }
    
}


/*:
 Next, you can play with this API, and see how convenient it is!
 */
//#-editable-code
var array = [Int](1 ... 20).shuffled()
print(array)

array.heapSort()
print(array)
array.heapSort(by: >)
print(array)

print(array.heapSorted())
print(array.heapSorted(by: >))


//#-end-editable-code
