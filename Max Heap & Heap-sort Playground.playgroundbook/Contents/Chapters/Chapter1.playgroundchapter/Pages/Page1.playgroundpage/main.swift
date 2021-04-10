import SwiftUI
import PlaygroundSupport

// let array = [16, 7, 22, 19, 12]

// MARK: - Public Functions

/*:
 Configures the max-heap or from an array, in a bottom-up manner.
 ## Complexity
 O(*n*)
 */
func heapify(heap: inout MaxHeap) {
    for i in stride(from: (heap.nodes.count / 2 - 1), through: 0, by: -1) {
        shiftDown(from: i, heap: &heap)
    }
}

/*:
 Shift up from a node recursively, until the heap property is restored.
 */
func shiftUp(_ index: Int, heap: inout MaxHeap) {
    if let p = heap.shiftUp(index) {
        shiftUp(p, heap: &heap)
    }
}

/*:
 Shift down from a node recursively, until the heap property is restored.
 */
func shiftDown(from index: Int, heap: inout MaxHeap) {
    let head = heap.shiftDown(from: index)
    shiftDown(from: head, heap: &heap)
}


// MARK: - View

struct ContentView: View {
    @StateObject private var viewModel = MaxHeapsort()
    @State private var text = ""
    @State private var isEditing = false
    @State private var sorted = [Node<Int>]()
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Input integers here (separated by space)", text: $text) { isEditing in
                    self.isEditing = isEditing
                } onCommit: {
                    var input = [Node<Int>]()
                    for str in text.split(separator: " ") {
                        if let value = Int(str) {
                            input.append(Node(value, id: original.count))
                        }
                    }
                    text.removeAll()
                    
                    viewModel = MaxHeapsort(from: input)
                    viewModel.heapify()
                }
                .disableAutocorrection(true)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            
            arrayView(viewModel.nodes)
                .background(Color.blue)
            
            Spacer()
            
            if !viewModel.isEmpty {
                TreeView(tree: viewModel.tree!)
                    .padding()
            }
            
            Spacer()
            
            arrayView(sorted)
                .background(Color.green)
            
            HStack {
//                button("Make Heap") {
//                    while !original.isEmpty {
//                        viewModel.insert(original.removeFirst())
//                    }
//                }
//                Spacer()
                button("Sort") {
                    while !viewModel.isEmpty {
                        sorted.append(viewModel.remove()!)
                    }
                }
            }
            .padding()
        }
    }
}

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
        .frame(height: DrawingConstants.nodeSize + DrawingConstants.edgePadding / 2)
        .padding(.leading, DrawingConstants.edgePadding)
        .padding(.trailing, DrawingConstants.edgePadding)
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
        .background(Color.accentColor)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.edgePadding, style: .continuous))
    }
}


PlaygroundPage.current.setLiveView(ContentView())
