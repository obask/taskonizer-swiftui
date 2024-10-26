import SwiftUI
import AppKit

class KeyEventHandlingNSView: NSView {
    var onKeyDown: ((NSEvent) -> Void)?

    override var acceptsFirstResponder: Bool {
        return true
    }

    override func keyDown(with event: NSEvent) {
        onKeyDown?(event)
    }
}

struct KeyEventHandlingView: NSViewRepresentable {
    var onKeyDown: (NSEvent) -> Void
    @Binding var viewReference: KeyEventHandlingNSView?

    func makeNSView(context: Context) -> KeyEventHandlingNSView {
        let view = KeyEventHandlingNSView()
        view.onKeyDown = onKeyDown
        DispatchQueue.main.async {
            viewReference = view
        }
        return view
    }

    func updateNSView(_ nsView: KeyEventHandlingNSView, context: Context) {
        // No update logic needed
    }
}
