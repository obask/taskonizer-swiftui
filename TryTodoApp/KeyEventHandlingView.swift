import SwiftUI
import AppKit

struct KeyEventHandlingView: NSViewRepresentable {
    var onKeyDown: (NSEvent) -> Void

    func makeNSView(context: Context) -> KeyEventHandlingNSView {
        let view = KeyEventHandlingNSView()
        view.onKeyDown = onKeyDown  // Set the key down handler
        return view
    }

    func updateNSView(_ nsView: KeyEventHandlingNSView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {}

    // Method to regain focus
    func regainFocus(_ nsView: NSView) {
        (nsView as? KeyEventHandlingNSView)?.regainFocus()
    }
}
