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

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.makeFirstResponder(self)  // Make sure the view is the first responder to capture key events
    }
    
    func regainFocus() {
        window?.makeFirstResponder(self)  // Re-establish first responder status
    }
}
