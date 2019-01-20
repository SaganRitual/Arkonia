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

class Visualizer: SKScene {
    typealias UpdateCallback = () -> ()

    let cChannels = 4
    var alreadyDidMoveTo = false
    var updateCallback: UpdateCallback = { }

    lazy var dashboard = makeDashboard(cChannels: cChannels, scene: self)
    lazy var displayChannel = dashboard.getChannel()
    lazy var vNet = makeNet()

    override func didMove(to view: SKView) {
        if alreadyDidMoveTo { return }

        let spriteAtlas = SKTextureAtlas(named: "Neurons")
        ArkonCentral.channelBackgroundTexture = spriteAtlas.textureNamed("channel-background")
        ArkonCentral.orangeNeuronSpriteTexture = spriteAtlas.textureNamed("neuron-orange")
        ArkonCentral.blueNeuronSpriteTexture = spriteAtlas.textureNamed("neuron-blue")
        ArkonCentral.greenNeuronSpriteTexture = spriteAtlas.textureNamed("neuron-green")

        alreadyDidMoveTo = true
    }

    override func didFinishUpdate() {
        if WildGuessWindowController.windowDimensions == CGSize() { print("!", terminator: ""); return}
        updateCallback() }

    func setUpdateCallback(_ updateCallback: @escaping UpdateCallback) {
        self.updateCallback = updateCallback
    }

    func makeDashboard(cChannels: Int, scene: SKScene) -> VDashboard {
        return VDashboard(cChannels: cChannels, scene: scene)
    }

    func makeNet() -> VNet {
        let netID = KIdentifier("T-Pattern", 0)
        return VNet(id: netID, visualizer: self)
    }

//    required init?(coder aDecoder: NSCoder) { fatalError("Required init in Visualizer?") }
}

extension Visualizer {
    struct VGridSize {
        var width: Int
        var height: Int

        init(width: Int, height: Int) {
            self.width = width
            self.height = height
        }
    }

    struct VGridPosition {
        var x: Int
        var y: Int

        init(x: Int, y: Int) {
            self.x = x
            self.y = y
        }
    }
}
