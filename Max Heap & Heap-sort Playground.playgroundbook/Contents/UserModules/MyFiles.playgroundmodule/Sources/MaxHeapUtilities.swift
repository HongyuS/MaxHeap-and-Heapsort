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

public struct Tree<T> {
    public var value: T
    public var children: [Tree<T>] = []
    public init(_ value: T, children: [Tree<T>] = []) {
        self.value = value
        self.children = children
    }
}
