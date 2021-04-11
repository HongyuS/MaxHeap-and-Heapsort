//
//  MaxHeapView.swift
//
//  Copyright © 2021 Hongyu Shi. All rights reserved.
//

import SwiftUI

// MARK: - Tree View
public struct TreeView: View {
    let tree: Tree<Node<Int>>
    
    public init(_ tree: Tree<Node<Int>>) {
        self.tree = tree
    }
    
    typealias Key = CollectDict<Node<Int>.ID, Anchor<CGPoint>>
    
    public var body: some View {
        VStack(alignment: .center) {
            NodeView(node: tree.value)
                .anchorPreference(key: Key.self, value: .center) {
                    [self.tree.value.id: $0]
                }
            HStack(alignment: .top, spacing: DrawingConstants.nodeSize) {
                ForEach(tree.children, id: \.value.id) { child in
                    TreeView(child)
                }
            }
        }
        .backgroundPreferenceValue(Key.self) { (centers: [Node<Int>.ID: Anchor<CGPoint>]) in
            GeometryReader { proxy in
                ForEach(self.tree.children, id: \.value.id) { child in
                    Line(
                        from: proxy[centers[self.tree.value.id]!],
                        to: proxy[centers[child.value.id]!]
                    ).stroke()
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
    
    public init(node: Node<Int>) {
        self.node = node
    }
    
    public var body: some View {
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
    var animatableData: AnimatablePair<CGPoint.AnimatableData, CGPoint.AnimatableData> {
        get { AnimatablePair(from.animatableData, to.animatableData) }
        set {
            from.animatableData = newValue.first
            to.animatableData = newValue.second
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
public struct DrawingConstants {
    public static let nodeSize: CGFloat = 36
    public static let edgePadding: CGFloat = 16
    public static let duration: Double = 0.5
}
