import Cocoa
import Foundation
import SpriteKit
//import IOKit
import IOKit.pwr_mgt

class AppController: NSObject {

    /// Shared singleton object
    static let shared = AppController()

    private(set) var mainWindowController = NSWindowController()

    var sceneViewController: SceneViewController? {
        return mainWindowController.contentViewController as? SceneViewController
    }

    var sceneView: SKView? {
        return sceneViewController?.view as? SKView
    }

    var scene: SKScene? {
        return sceneViewController?.scene
    }

    // We make the constructor private, so noone can create object from this class
    // There's only one such object, the shared singleton which we created above
    private override init() {
        super.init()
    }

    func showMainWindow(withTitle title: String) {
        let reasonForActivity = "Arkonia is running" as CFString
        var assertionID: IOPMAssertionID = 0
        var success = IOPMAssertionCreateWithName( kIOPMAssertionTypeNoDisplaySleep as CFString,
                                                    IOPMAssertionLevel(kIOPMAssertionLevelOn),
                                                    reasonForActivity,
                                                    &assertionID )
        if success == kIOReturnSuccess {
            // Add the work you need to do without the system sleeping here.

            success = IOPMAssertionRelease(assertionID)
            // The system will be able to sleep again.
        }

        // Create controller's window if not yet exists
        if mainWindowController.window == nil {
            // Count initial frame
            let newFrame: NSRect
            let aspectRatioOfRobsMacbookPro: CGFloat = 2880 / 1800
            if let screenFrame = NSScreen.main?.visibleFrame {
                // We got the screen dimensions, count the frame from them
                // visibleFrame is the screen size excluding menu bar (on top of the screen)
                // and dock (by default on bottom)
                let newWidth = screenFrame.width * 0.7
                let newHeight = newWidth / aspectRatioOfRobsMacbookPro
                let newSize = NSSize(width: newWidth, height: newHeight)

                let newOrigin = CGPoint(x: screenFrame.origin.x + (screenFrame.width  - newSize.width),
                                        y: screenFrame.origin.y + (screenFrame.height - newSize.height))
                newFrame = NSRect(origin: newOrigin, size: newSize)
            } else {
                // We have no clue about scren dimensions, set static size
                newFrame = NSRect(origin: NSPoint(x: 50, y: 100), size: NSSize(width: 1500, height: 850))
            }

            // Create scene view controller for the counted frame
            let sceneViewController = SceneViewController(frame: newFrame)

            // Create window holding the scene view of sceneViewController
            mainWindowController.window = NSWindow(contentViewController: sceneViewController)

            // Set window's style (add title and system buttons)
            mainWindowController.window?.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            mainWindowController.window?.title = title
            mainWindowController.window?.aspectRatio = CGSize(width: aspectRatioOfRobsMacbookPro, height: 1)

            // Set window initial position and frame
            mainWindowController.window?.setFrame(newFrame, display: false)
        }

        // Show the window
        mainWindowController.window?.makeKeyAndOrderFront(self)
    }

}
