//#-hidden-code
//
//  main.swift
//
//  Copyright © 2021 Hongyu Shi. All rights reserved.
//

import SwiftUI
import PlaygroundSupport
//#-end-hidden-code
/*:
 # BIM3009 Assignment III - Max Heap-sort #
 
 **Implementation of Max Heap and Heapsort**

 **Requirments:** Please refer to the section "Heaps" of *Chapter 5* to construct a max heap for a given sequence of unsorted numbers. After the construction of **max heap**, please implement a **heapsort** by using the constructed max heap, with reference to the heapsort algorithm mentioned in *Chapter 6*.

 **Input**: A sequence of unsorted numbers, such as: 16, 7, 22, 19, and 12.
 
 **Graphical Interface Instructions**:
 
 - Type in a sequence of integers in the *Text Field*. The inputs should be separated by space. Invalid inputs will be omitted.
 
 - The upper *Gray Area* shows the real-time status of the max heap, represented in array.
 
 - The lower *Gray Area* shows the sorted array dynamicly in real-time.
 
 Perss "Next Step" button to sort the array step by step. If the input array is empty, or is fully sorted, the "Next Step" button will be disabled.
 You can input another array of integers when the previous array is fully sorted.
 
 **GitHub Page**:
 https://github.com/HongyuS/MaxHeap-and-Heapsort
 */
// let array = [16, 7, 22, 19, 12]

// MARK: - Public Functions
/*:
 Configures the max-heap or from an array, in a bottom-up manner.
 
 **Complexity**: O(*n*)
 */
//#-editable-code
func heapify(heap: inout MaxHeap<Node<Int>>) {
    for i in stride(from: (heap.nodes.count / 2 - 1), through: 0, by: -1) {
        shiftDown(from: i, heap: &heap)
    }
}
//#-end-editable-code
/*:
 Shift up from a node recursively, until the heap property is restored.
 
 **Complexity**: O(log *n*)
 */
//#-editable-code
func shiftUp(_ index: Int, heap: inout MaxHeap<Node<Int>>) {
    if let p = heap.shiftUp(index) {
        shiftUp(p, heap: &heap)
    }
}
//#-end-editable-code
/*:
 Shift down from a node recursively, until the heap property is restored.
 
 **Complexity**: O(log *n*)
 */
//#-editable-code
func shiftDown(from index: Int, heap: inout MaxHeap<Node<Int>>) {
    if let head = heap.shiftDown(from: index) {
        shiftDown(from: head, heap: &heap)
    }
}
//#-end-editable-code

// MARK: - View Model

class MaxHeapsort: ObservableObject {
    // This class handles communications between
    // the view and the max heap.
    // Inplementation is hidden here, but if you
    // are interested, you may check it on GitHub.
    //#-hidden-code
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
    
    func heapify() {
        Page_Contents.heapify(heap: &self.heap)
    }
    
    func insert(_ node: Node<Int>) {
        heap.nodes.append(node)
        shiftUp(count - 1, heap: &self.heap)
    }
    
    func remove() -> Node<Int>? {
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
    
    func reset(from array: [Node<Int>]) {
        heap.reset(from: array)
    }
    
    //#-end-hidden-code
}


// MARK: - View

struct ContentView: View {
    /// View Model
    @StateObject private var viewModel = MaxHeapsort()
    
    // View states
    /// Text field state: text
    @State private var text = ""
    /// Text field state: is editing
    @State private var isEditing = false
    /// Sorted array
    @State private var sorted = [Node<Int>]()
    
    var body: some View {
        VStack(spacing: 0) {
            
            /// Text Field View (Implementations are hidden)
            //#-hidden-code
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
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .disabled(!viewModel.isEmpty)
            //#-end-hidden-code
            
            /// Displays the heap as an array.
            arrayView(viewModel.nodes)
                .padding(.horizontal)
            
            Spacer()
            
            /// Displays the heap as a tree.
            if !viewModel.isEmpty {
                TreeView(viewModel.tree!)
                    .padding()
            }
            
            Spacer()
            
            /// Displays the sorted array.
            arrayView(sorted)
                .padding(.horizontal)
            
            /// "Next Step" Button
            button("Next Step") {
                if !viewModel.isEmpty {
                    sorted.append(viewModel.remove()!)
                }
            }
            .padding()
            .disabled(viewModel.isEmpty)
        }
    }
}

//#-hidden-code
extension ContentView {
    @ViewBuilder func arrayView(_ array: [Node<Int>]) -> some View {
        let rows = [GridItem](repeating: .init(.fixed(DrawingConstants.nodeSize)), count: 1)
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, alignment: .center) {
                ForEach(array) { node in
                    NodeView(node: node)
                }
            }
        }
        .frame(height: DrawingConstants.nodeSize + DrawingConstants.edgePadding)
        .padding(.leading, DrawingConstants.edgePadding / 2)
        .padding(.trailing, DrawingConstants.edgePadding / 2)
        .background(Color.accentColor.opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.edgePadding / 2, style: .continuous))
    }
    
    @ViewBuilder func button(_ label: String, action: @escaping () -> ()) -> some View {
        Button {
            withAnimation(.easeInOut(duration: DrawingConstants.duration)) {
                action()
            }
        } label: {
            Text(label)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding(DrawingConstants.edgePadding)
        .background(viewModel.isEmpty ? Color.secondary : Color.green)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.edgePadding, style: .continuous))
    }
}

PlaygroundPage.current.setLiveView(ContentView())
//#-end-hidden-code
