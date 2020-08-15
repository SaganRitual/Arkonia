import Cocoa
import SwiftUI

class LineChartApp_MockLineData: LineChartLineDataProtocol {
    func getPlotPoints() -> [CGPoint] {
        print("getpltpoint52")
        return (Int(0)..<Int(10)).map {
            CGPoint(x: Double($0) / 10, y: Double.random(in: 0..<1))
        }
    }
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let contentRect = NSRect(x: 0, y: 0, width: 480, height: 300)

        // Create the SwiftUI view that provides the window contents.
        let contentView =
            ContentView()
            .environmentObject(MockLineChartControls.controls)

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: contentRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

