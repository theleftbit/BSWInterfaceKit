#if canImport(UIKit)

import SwiftUI

#Preview {
    ContentView(items: [
        .init(
            id: 0,
            systemImageName: "person.circle",
            description: "Description"
        )
    ])
}

private struct ContentView: View {
    
    struct Item: Identifiable {
        let id: Int
        let systemImageName: String
        let description: String
    }
    var items: [Item]
    
    @State
    var presentingDetailsOfItem: Item?
    
    var body: some View {
        HStack {
            ForEach(items, id: \.id) { item in
                Button {
                    presentingDetailsOfItem = item
                } label: {
                    Image(systemName: item.systemImageName)
                        .alwaysPopover(id: item.id, isPresented: $presentingDetailsOfItem) {
                            Text(item.description)
                                .lineLimit(nil)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                }

            }
        }
    }
}

public extension View {
    
    func alwaysPopover<Content: View, Value: Identifiable>(id: Value.ID, isPresented: Binding<Value?>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(AlwaysPopoverModifier(id: id, isPresented: isPresented, contentBlock: content))
    }
}

private struct AlwaysPopoverModifier<PopoverContent: View, Value: Identifiable>: ViewModifier {
    
    let id: Value.ID
    let isPresented: Binding<Value?>
    let contentBlock: () -> PopoverContent
    @State private var anchorView = UIView()
    
    func body(content: Content) -> some View {
        if let value = isPresented.wrappedValue, value.id == id {
            presentPopover(value: value)
        }
        
        return content
            .background(InternalAnchorView(uiView: anchorView))
    }
    
    func presentPopover(value: Value) {
        let contentController = ContentViewController(
            // Ensures the text wraps to fit the content
            rootView: contentBlock()
                .fixedSize(horizontal: false, vertical: true),
            isPresented: isPresented
        )
        contentController.modalPresentationStyle = .popover
        
        let view = anchorView
        guard let popover = contentController.popoverPresentationController else { return }
        popover.sourceView = view
        popover.sourceRect = view.bounds
        popover.delegate = contentController
        
        guard let sourceVC = view.next() as UIViewController? else { return }
        sourceVC.present(contentController, animated: true)
    }
    
    struct InternalAnchorView: UIViewRepresentable {
        let uiView: UIView
        
        func makeUIView(context: Self.Context) -> UIView {
            uiView
        }
        
        func updateUIView(_ uiView: UIView, context: Self.Context) { }
    }
    
    class ContentViewController<FinalView: View>: UIHostingController<FinalView>, UIPopoverPresentationControllerDelegate {
        
        var isPresented: Binding<Value?>
        
        init(rootView: FinalView, isPresented: Binding<Value?>) {
            self.isPresented = isPresented
            super.init(rootView: rootView)
        }
        
        @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            updatePreferredContentSize()
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            updatePreferredContentSize()
        }
        
        private let MaxWidth: CGFloat = 320
        
        private func updatePreferredContentSize() {
            let size = view.systemLayoutSizeFitting(
                CGSize(width: MaxWidth, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            preferredContentSize = size
        }
        
        // MARK: UIPopoverPresentationControllerDelegate
        
        func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
            return .none
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            self.isPresented.wrappedValue = nil
        }
    }
}

#endif
