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

import Foundation
import SpriteKit

class VScene: SKScene {
    typealias UpdateCallback = (_ portal: SKNode) -> ()

    // It's not reasonable to depend on the callbacks being called
    // only one time.
    var alreadyDidMoveTo = false

    // It's not reasonable to depend on the callbacks from happening in
    // a reasonable order. Let's ignore everything until we've seen a second's
    // worth of didFinishUpdate(), and then we'll get going.
    var waitForIt = 0

    var updateCallbacks = [() -> ()]()
    var visionTester: VisionTest!

    override func didMove(to view: SKView) {
        if alreadyDidMoveTo { return }

        self.size = view.frame.size

        let spriteAtlas = SKTextureAtlas(named: "Neurons")
        ArkonCentral.sceneBackgroundTexture = spriteAtlas.textureNamed("scene-background")
        ArkonCentral.orangeNeuronSpriteTexture = spriteAtlas.textureNamed("neuron-orange")
        ArkonCentral.blueNeuronSpriteTexture = spriteAtlas.textureNamed("neuron-blue")
        ArkonCentral.greenNeuronSpriteTexture = spriteAtlas.textureNamed("neuron-green")

        alreadyDidMoveTo = true
    }

    override func didFinishUpdate() {
        waitForIt += 1  // Notes above
        if waitForIt < 60 { return }
        if waitForIt == 60 { visionTester = VisionTest(self); return }

        updateCallbacks.forEach { $0() }
    }

    func setUpdateCallback(_ cb: @escaping UpdateCallback, portal: SKNode) {
        updateCallbacks.append({ cb(portal) })
    }
}
