//
//  MaxHeapViewModel.swift
//
//  Copyright © 2021 Hongyu Shi. All rights reserved.
//

import SwiftUI

public class MaxHeapsort: ObservableObject {
    @Published private var heap = MaxHeap<Node<Int>>()
    
    public init(from array: [Node<Int>]) {
        heap = MaxHeap(array: array)
    }
    
    // MARK: Access to the model
    // because it's a private var
    public var nodes: [Node<Int>] { heap.nodes }
    public var tree: Tree<Node<Int>>? { heap.tree }
    public var isEmpty: Bool { heap.isEmpty }
    public var count: Int { heap.count }
    
    // MARK: Intents
    
    public func heapify() {
        heapify(&self.heap)
    }
    
    public func insert(_ node: Node<Int>) {
        heap.nodes.append(node)
        shiftUp(count - 1, heap: &self.heap)
    }
    
    public func remove() -> Node<Int>? {
        guard !isEmpty else { return nil }
        
        if count == 1 {
            return heap.nodes.removeLast()
        } else {
            let value = nodes[0]
            heap.nodes[0] = heap.nodes.removeLast()
            shiftDown(from: 0, heap: &self.heap)
            return value
        }
    }
    
    public func peek() -> Node<Int>? {
        heap.peek()
    }
    
}
