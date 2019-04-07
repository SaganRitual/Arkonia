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

class SceneViewController: NSViewController {

    var scene: SKScene?

	init(frame: NSRect) {
		super.init(nibName: nil, bundle: nil)
		self.view = SKView(frame: frame)
		initializeScene()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.view = SKView(frame: self.view.frame)
		initializeScene()
	}

	private func initializeScene() {
		guard let view = view as? SKView else { return }

        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true
        view.showsDrawCount = true
//        view.isAsynchronous = false
        view.showsPhysics = true

		let scene = SKScene(fileNamed: "GameScene")!

        self.scene = scene

		// Set the scale mode to scale to fit the window
		scene.scaleMode = .fill
		scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		scene.size = view.frame.size

		view.presentScene(scene)

        DBootstrap(scene).launch()
	}

}
