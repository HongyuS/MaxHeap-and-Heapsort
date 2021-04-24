//
//  MaxHeapView.swift
//
//  Copyright © 2021 Hongyu Shi. All rights reserved.
//

import SwiftUI

// MARK: - Content View
public struct ContentView: View {
    /// View Model
    @StateObject private var viewModel = MaxHeapsort()
    
    // View states
    /// Text field state: text
    @State private var text = ""
    /// Text field state: is editing
    @State private var isEditing = false
    /// Sorted array
    @State private var sorted = [Node<Int>]()
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            
            /// Text Field View
            TextField("Input integers here (separated by space)", text: $text) { isEditing in
                self.isEditing = isEditing
            } onCommit: {
                sorted.removeAll()
                var input = [Node<Int>]()
                for str in text.split(separator: " ") {
                    if let value = Int(str) {
                        input.append(Node(value, id: input.count))
                    }
                }
                text.removeAll()
                
                viewModel.reset(from: input)
                viewModel.heapify()
            }
            .disableAutocorrection(true)
            .keyboardType(.numbersAndPunctuation)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .disabled(!viewModel.isEmpty)
            
            /// Displays the heap as an array.
            arrayView(viewModel.nodes, label: "Heap")
                .padding(.horizontal)
            
            Spacer()
            
            /// Displays the heap as a tree.
            if !viewModel.isEmpty {
                TreeView(viewModel.tree!)
                    .padding()
            }
            
            Spacer()
            
            /// Displays the sorted array.
            arrayView(sorted, label: "Sorted")
                .padding(.horizontal)
            
            /// "Next Step" Button
            button("play.fill", "Next Step") {
                if !viewModel.isEmpty {
                    sorted.append(viewModel.remove()!)
                }
            }
            .padding()
            .disabled(viewModel.isEmpty)
        }
    }
}

extension ContentView {
    @ViewBuilder private func arrayView(_ array: [Node<Int>], label: String) -> some View {
        let rows = [GridItem](repeating: .init(.fixed(DrawingConstants.nodeSize)), count: 1)
        
        HStack(spacing: DrawingConstants.edgePadding / 2) {
            Text(label)
                .font(.headline)
                .frame(width: DrawingConstants.textLabelWidth, height: DrawingConstants.nodeSize + DrawingConstants.edgePadding)
                .padding(.horizontal, DrawingConstants.edgePadding / 2)
                .background(Color.accentColor.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.edgePadding / 2, style: .continuous))
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: rows, alignment: .center) {
                    ForEach(array) { node in
                        NodeView(node: node)
                    }
                }
            }
            .frame(height: DrawingConstants.nodeSize + DrawingConstants.edgePadding)
            .padding(.horizontal, DrawingConstants.edgePadding / 2)
            .background(Color.accentColor.opacity(0.75))
            .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.edgePadding / 2, style: .continuous))
        }
    }
    
    @ViewBuilder private func button(_ icon: String, _ label: String, action: @escaping () -> ()) -> some View {
        Button {
            withAnimation(.easeInOut(duration: DrawingConstants.duration)) {
                action()
            }
        } label: {
            HStack(spacing: DrawingConstants.edgePadding / 1.333) {
                Image(systemName: icon)
                Text(label)
            }
            .font(.headline)
            .foregroundColor(.white)
        }
        .padding(DrawingConstants.edgePadding)
        .background(viewModel.isEmpty ? Color.secondary : Color.green)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.edgePadding, style: .continuous))
    }
}


// MARK: - Tree View
struct TreeView: View {
    let tree: Tree<Node<Int>>
    
    init(_ tree: Tree<Node<Int>>) {
        self.tree = tree
    }
    
    typealias Key = CollectDict<Node<Int>.ID, Anchor<CGPoint>>
    
    var body: some View {
        VStack(alignment: .center) {
            NodeView(node: tree.value)
                .padding(.top, DrawingConstants.edgePadding)
                .anchorPreference(key: Key.self, value: .center) {
                    [self.tree.value.id: $0]
                }
            
            HStack(alignment: .center, spacing: DrawingConstants.nodeSize) {
                ForEach(tree.children, id: \.value.id) { child in
                    TreeView(child)
                }
                
                if tree.children.count < 2 {
                    Spacer()
                }
            }
            
            Spacer()
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
struct NodeView: View {
    let node: Node<Int>
    
    init(node: Node<Int>) {
        self.node = node
    }
    
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
struct DrawingConstants {
    static let nodeSize: CGFloat = 36
    static let edgePadding: CGFloat = 16
    static let textLabelWidth: CGFloat = 76
    static let duration: Double = 0.5
}
