//
//  MaxHeapUtilities.swift
//
//  Copyright © 2021 Hongyu Shi. All rights reserved.
//

public struct Node<T>: Comparable, Identifiable where T: Comparable {
    public let id: Int
    public let value: T
    
    public init(_ value: T, id: Int) {
        self.id = id
        self.value = value
    }
    
    public static func < (left: Self, right: Self) -> Bool {
        left.value < right.value
    }
    public static func == (left: Self, right: Self) -> Bool {
        left.value == right.value
    }
}

public struct Tree<T> where T: Identifiable {
    
    public var value: T
    public var children: [Tree<T>] = []
    
    public init(_ value: T, children: [Tree<T>] = []) {
        self.value = value
        self.children = children
    }
    
    public init(array: [T]) {
        assert(!array.isEmpty, "Array is empty")
        var left = [T]
        var right = [T]
        for i in 1 ..< array.count {
            if isLeftChild(i) {
                left.append(array[i])
            } else {
                right.append(array[i])
            }
        }
        self.value = array[0]
        self.children = [Tree(array: left), Tree(array: right)]
        
    }
    
    private static func parentIndex(ofIndex i: Int) -> Int {
        return (i - 1) / 2
    }
    
    private static func isLeftChild(_ index: Int) -> Bool {
        if index > 2 {
            return isLeftChild(parentIndex(ofIndex: index))
        } else if index == 1 {
            return true
        } else if index == 2 {
            return false
        }
        return false
    }
}
