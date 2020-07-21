//
//  AppDelegate.swift
//  Fletch
//
//  Created by Rob Bishop on 7/13/20.
//  Copyright © 2020 Boring Software. All rights reserved.
//

import Cocoa
import Dispatch
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var preferencesWindow: NSWindow!

    @objc func openPreferencesWindow() {
        if nil == preferencesWindow {      // create once !!
            let preferencesView = LineChartView().environmentObject(LineChartData(6))
            // Create the preferences window and set content
            preferencesWindow = NSWindow(
                contentRect: NSRect(x: 20, y: 20, width: 480, height: 300),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered,
                defer: false)
            preferencesWindow.center()
            preferencesWindow.setFrameAutosaveName("Preferences")
            preferencesWindow.isReleasedWhenClosed = false
            preferencesWindow.contentView = NSHostingView(rootView: preferencesView)
        }
        preferencesWindow.makeKeyAndOrderFront(nil)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
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

        ArkoniaLayout.SeasonFactorView.bgFrameHeight = newFrame.height
        ArkoniaLayout.SeasonFactorView.stickGrooveFrameHeight = newFrame.height

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView().frame(width: newFrame.width, height: newFrame.height)

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: newFrame,
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )

        window.center()
        window.setFrameAutosaveName("Arkonia")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
