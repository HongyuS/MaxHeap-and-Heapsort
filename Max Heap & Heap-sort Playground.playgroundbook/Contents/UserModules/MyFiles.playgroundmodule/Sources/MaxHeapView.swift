//
//  MaxHeapView.swift
//
//  Copyright © 2021 Hongyu Shi. All rights reserved.
//

import SwiftUI

// MARK: - Tree View
public struct TreeView: View {
    let tree: Tree<Node<Int>>
    
    typealias Key = CollectDict<Node<Int>.ID, Anchor<CGPoint>>
    
    var body: some View {
        VStack(alignment: .center) {
            NodeView(node: tree.value)
                .anchorPreference(key: Key.self, value: .center) {
                    [self.tree.value.id: $0]
                }
            HStack(alignment: .top, spacing: DrawingConstants.nodeSize) {
                ForEach(tree.children, id: \.value.id) { child in
                    TreeView(tree: child)
                }
            }
        }
    }
}

struct CollectDict<Key: Hashable, Value>: PreferenceKey {
    static var defaultValue: [Key: Value] { [:] }
    static func reduce(value: inout [Key : Value], nextValue: () -> [Key : Value]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}


// MARK: - Node View
public struct NodeView: View {
    let node: Node<Int>
    var body: some View {
        Text("\(node.value)")
            .nodity()
    }
}

struct Nodity: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: DrawingConstants.nodeSize, height: DrawingConstants.nodeSize, alignment: .center)
            .background(Circle().stroke())
            .background(Circle().fill(Color(.secondarySystemBackground)))
            .padding(2)
            .shadow(radius: 2)
    }
}

extension View {
    func nodity() -> some View {
        self.modifier(Nodity())
    }
}

/// Lines connecting the nodes.
struct Line: Shape {
    var from: CGPoint
    var to: CGPoint
    var animatableData: AnimatablePair<CGPoint, CGPoint> {
        get { AnimatablePair(from, to) }
        set {
            from = newValue.first
            to = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: self.from)
            p.addLine(to: self.to)
        }
    }
}


// MARK: - Drawing Constants
struct DrawingConstants {
    static let nodeSize: CGFloat = 36
    static let edgePadding: CGFloat = 16
    static let duration: Double = 0.5
}
