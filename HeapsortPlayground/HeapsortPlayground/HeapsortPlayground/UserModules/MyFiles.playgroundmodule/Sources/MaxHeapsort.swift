//
//  MaxHeapsort.swift
//  UserModule
//
//  Created by Hongyu Shi on 2021/4/24.
//

import SwiftUI

// MARK: - View Model
class MaxHeapsort: ObservableObject {
    
    @Published private var heap = MaxHeap<Node<Int>>()
    
    init() {}
    
    init(from array: [Node<Int>]) {
        heap = MaxHeap(array: array)
    }
    
    // MARK: Access to the model
    // because it's a private var
    var nodes: [Node<Int>] { heap.nodes }
    var tree: Tree<Node<Int>>? { heap.tree }
    var isEmpty: Bool { heap.isEmpty }
    var count: Int { heap.count }
    
    // MARK: Intents
    
    func reset(from array: [Node<Int>]) {
        heap.reset(from: array)
    }
    
    func heapify() {
        heap.heapify()
    }
    
    func insert(_ node: Node<Int>) {
        heap.insert(node)
    }
    
    @discardableResult func remove() -> Node<Int>? {
        heap.remove()
    }
    
    func shiftUp(_ index: Int) -> Int? {
        heap.shiftUp(index)
    }
    
    func shiftDown(from index: Int) -> Int? {
        heap.shiftDown(from: index)
    }
}
