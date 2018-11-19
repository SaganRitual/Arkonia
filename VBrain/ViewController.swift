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
    static var windowDimensions = CGSize()
    
    override func windowDidLoad() {
        if let screenSize = window?.screen?.frame {
            let newHeight = screenSize.height * 0.5
            let newWidth = screenSize.width * 0.5
            let newX = 100//(screenSize.width - newWidth) / 2
            let newY = 500 //2 * (screenSize.height - newHeight) / 3
            
            let newSize = CGSize(width: newWidth, height: newHeight)
            let newOrigin = CGPoint(x: newX, y: newY)
            
            let newFrame = NSRect(origin: newOrigin, size: newSize)
            WildGuessWindowController.windowDimensions = newSize
            
            window!.setFrame(newFrame, display: true)
        }
        
        super.windowDidLoad()
    }
}

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}

