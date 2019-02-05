//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//

import Cocoa
import Foundation
import SpriteKit

class KAppController: NSObject {

	/// Shared singleton object
	static let shared = KAppController()

	private(set) var mainWindowController = NSWindowController()

	var sceneViewController:SceneViewController? {
		return mainWindowController.contentViewController as? SceneViewController
	}

	var sceneView:SKView? {
		return sceneViewController?.view as? SKView
	}

	var scene:SKScene? {
		return sceneViewController?.scene
	}

	// We make the constructor private, so noone can create object from this class
	// There's only one such object, the shared singleton which we created above
	private override init() {
		super.init()
	}

	func showMainWindow(withTitle title: String) {

		// Create controller's window if not yet exists
		if mainWindowController.window == nil {
			// Count initial frame
			let newFrame:NSRect
			if let screenFrame = NSScreen.main?.visibleFrame {
				// We got the screen dimensions, count the frame from them
				// visibleFrame is the screen size excluding menu bar (on top of the screen) and dock (by default on bottom)
				let newSize = NSSize(width: screenFrame.width * 0.7,
									 height: screenFrame.height * 0.7)

				let newOrigin = CGPoint(x: screenFrame.origin.x - (screenFrame.width  - newSize.width),
										y: screenFrame.origin.y + (screenFrame.height - newSize.height))
				newFrame = NSRect(origin: newOrigin, size: newSize)
			}
			else {
				// We have no clue about scren dimensions, set static size
				newFrame = NSRect(origin: NSPoint(50, 100), size: NSSize(width: 1500, height: 850))
			}

			// Create scene view controller for the counted frame
			let sceneViewController = SceneViewController(frame: newFrame)

			// Create window holding the scene view of sceneViewController
			mainWindowController.window = NSWindow(contentViewController: sceneViewController)

			// Set window's style (add title and system buttons)
			mainWindowController.window?.styleMask = [.titled, .closable, .miniaturizable, .resizable]
			mainWindowController.window?.title = title

			// Set window initial position and frame
			mainWindowController.window?.setFrame(newFrame, display: false)
		}

		// Show the window
		mainWindowController.window?.makeKeyAndOrderFront(self)
	}

}
