import SwiftUI
import PlaygroundSupport

//  let array = [16, 7, 22, 19, 12]
//  var heap = MaxHeap(array: array)
//  print(heap)
//  while !heap.isEmpty {
//      print(heap.remove()!)
//      print(heap)
//  }

// MARK: - Model
struct Node<T>: Comparable, Identifiable where T: Comparable {
    let id: Int
    let value: T
    
    init(_ value: T, id: Int) {
        self.id = id
        self.value = value
    }
    
    static func < (left: Self, right: Self) -> Bool {
        left.value < right.value
    }
    static func == (left: Self, right: Self) -> Bool {
        left.value == right.value
    }
}

extension MaxHeap where T: Identifiable {
    mutating func shiftUp(_ index: Int) -> Int? {
        guard let p = parentIndex(ofIndex: index) else { return nil }
        if nodes[index] > nodes[p] {
            nodes.swapAt(index, p)
            return p
        } else {
            return nil
        }
    }
    
    mutating func shiftDown(from index: Int) -> Int? {
        var head = index
        if let i = leftChildIndex(ofIndex: index), nodes[i] > nodes[head] {
            head = i
        }
        if let j = rightChildIndex(ofIndex: index), nodes[j] > nodes[head] {
            head = j
        }
        if head == index { return nil }
        
        nodes.swapAt(index, head)
        return head
    }
    
    func childern(of node: T) -> [T] {
        var children = [T]()
        guard let i = index(of: node) else { return children }
        guard let leftChildIndex = leftChildIndex(ofIndex: i) else { return children }
        children.append(nodes[leftChildIndex])
        guard let rightChildIndex = rightChildIndex(ofIndex: i) else { return children }
        children.append(nodes[rightChildIndex])
        return children
    }
    
    func index(of node: T) -> Int? {
        for i in 0 ..< count {
            if nodes[i].id == node.id {
                return i
            }
        }
        return nil
    }
}


// MARK: - ViewModel

class MaxHeapsort: ObservableObject {
    @Published private var heap = MaxHeap<Node<Int>>()
    
    // MARK: Access to the model
    // because it's a private var
    var nodes: [Node<Int>] { heap.nodes }
    var isEmpty: Bool { heap.isEmpty }
    var count: Int { heap.count }
    
    // MARK: Intents
    
    func insert(_ node: Node<Int>) {
        heap.nodes.append(node)
        delayedAutoShiftUp(count - 1)
    }
    
    func remove() -> Node<Int>? {
        guard !isEmpty else { return nil }
        
        if count == 1 {
            return heap.nodes.removeLast()
        } else {
            let value = nodes[0]
            heap.nodes[0] = heap.nodes.removeLast()
            delayedAutoShiftDown(from: 0)
            return value
        }
    }
    
    func delayedAutoShiftUp(_ index: Int) {
        if let parentIndex = heap.shiftUp(index) {
            delay(1) {
                self.delayedAutoShiftUp(parentIndex)
            }
        }
    }
    
    func delayedAutoShiftDown(from index: Int) {
        if let head = heap.shiftDown(from: index) {
            delay(1) {
                self.delayedAutoShiftDown(from: head)
            }
        }
    }
    
    func children(of node: Node<Int>) -> [Node<Int>] {
        heap.childern(of: node)
    }
    
    func peek() -> Node<Int>? {
        heap.peek()
    }
    
}


// MARK: - View

struct ContentView: View {
    @StateObject private var viewModel = MaxHeapsort()
    @State private var text = ""
    @State private var isEditing = false
    @State private var original = [Node<Int>]()
    @State private var sorted = [Node<Int>]()
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Input integers here (separated by space)", text: $text) { isEditing in
                    self.isEditing = isEditing
                } onCommit: {
                    original.removeAll()
                    for str in text.split(separator: " ") {
                        if let value = Int(str) {
                            original.append(Node(value, id: original.count))
                        }
                    }
                    text.removeAll()
                }
                .disableAutocorrection(true)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            
            arrayView(original)
                .background(Color.blue)
            
            Spacer()
            
            if !viewModel.isEmpty {
                HeapView(viewModel, root: viewModel.peek()!)
                    .padding()
            }
            
            Spacer()
            
            arrayView(sorted)
                .background(Color.green)
            
            HStack {
                button("Make Heap") {
                    while !original.isEmpty {
                        viewModel.insert(original.removeFirst())
                    }
                }
                Spacer()
                button("Sort") {
                    if !viewModel.isEmpty {
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

struct HeapView: View {
    var viewModel: MaxHeapsort
    let root: Node<Int>
    
    init(_ viewModel: MaxHeapsort, root: Node<Int>) {
        print(root.value)
        self.viewModel = viewModel
        self.root = root
    }
    
    typealias Key = CollectDict<Node<Int>.ID, Anchor<CGPoint>>
    
    var body: some View {
        VStack(alignment: .center) {
            NodeView(node: root)
                .anchorPreference(key: Key.self, value: .center) {
                    [self.root.id: $0]
                }
            HStack(alignment: .top, spacing: DrawingConstants.nodeSize) {
                ForEach(viewModel.children(of: self.root), id: \.id) { child in
                    HeapView(viewModel, root: child)
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

struct NodeView: View {
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

struct DrawingConstants {
    static let nodeSize: CGFloat = 36
    static let edgePadding: CGFloat = 16
    static let duration: Double = 0.5
}

// MARK: - Utilities
func delay(_ delay: Double, work: @escaping () -> ()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: work)
}


PlaygroundPage.current.setLiveView(ContentView())
