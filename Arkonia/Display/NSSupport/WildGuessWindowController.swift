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
import SpriteKit
import GameplayKit

class WildGuessWindowController: NSWindowController {
    static var windowAlreadyDidLoad = false

    override func windowDidLoad() {
        defer {
            WildGuessWindowController.windowAlreadyDidLoad = true
            super.windowDidLoad()
        }

        if WildGuessWindowController.windowAlreadyDidLoad { return }

        if let frame = window?.screen?.frame {
            let newHeight = frame.height * 0.7
            let newWidth = frame.width * 0.7

            // Upper left corner
            let newOrigin = CGPoint(x: -newWidth / 2.0, y: newHeight)
            let newSize = CGSize(width: newWidth, height: newHeight)
            let newFrame = NSRect(origin: newOrigin, size: newSize)

            window!.setFrame(newFrame, display: true)
        }

        // Uncomment to show window on second monitor (for debug)
        //
        // With profound gratitude to Kim
        // https://stackoverflow.com/users/8114750/kim
        // https://stackoverflow.com/q/44833427/1610473
        //
//        var pos = NSPoint()
//        pos.x = NSScreen.screens[1].visibleFrame.midX
//        pos.y = NSScreen.screens[1].visibleFrame.midY
//        self.window?.setFrameOrigin(pos)
    }
}
