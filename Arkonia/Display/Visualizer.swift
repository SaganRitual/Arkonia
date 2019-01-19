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

class Visualizer : SKScene {
    var workItem: DispatchWorkItem?
    var semaphore = DispatchSemaphore(value: 0)

    var alreadyDidMoveTo = false

    override func didMove(to view: SKView) {
        if alreadyDidMoveTo { return }

        let spriteAtlas = SKTextureAtlas(named: "Neurons")
        ArkonCentral.orangeNeuronSpriteTexture = spriteAtlas.textureNamed("neuron-orange")
        ArkonCentral.blueNeuronSpriteTexture = spriteAtlas.textureNamed("neuron-blue")
        ArkonCentral.greenNeuronSpriteTexture = spriteAtlas.textureNamed("neuron-green")

        alreadyDidMoveTo = true
    }

    typealias UC = () -> ()
    var updateCallback: UC?

    override func didFinishUpdate() { updateCallback?() }

    func setUpdateCallback(_ updateCallback: @escaping UC) {
        self.updateCallback = updateCallback
    }
}

struct VNetDescriptor {
    let cLayers: Int
    let cNeurons: [Int]

    init(_ cLayers: Int, _ cNeurons: [Int]) {
        self.cLayers = cLayers
        self.cNeurons = cNeurons
    }
}
