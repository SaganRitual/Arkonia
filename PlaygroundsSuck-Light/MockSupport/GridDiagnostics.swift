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

#if SIGNAL_GRID_DIAGNOSTICS
extension GameScene {
    
}

protocol VGridProtocol {
    var gameScene: GameScene { get }
    var labelBackground: SKShapeNode! { get set }
    var kNet: KNet { get set }
    var spacer: Spacer! { get set }
    var vBrainSceneSize: CGSize { get set }
    var vNeurons: [SKShapeNode] { get set }

    init(gameScene: GameScene, kNet: KNet, sceneSize: CGSize)

    func displayGrid(_ sensoryInputs: KLayer)
    func displayNet(_ sensoryInputs: KLayer, _ kNet: KNet)
    func displayLayers(_ sensoryInput: KLayer, _ kLayers: [KLayer])

    func makeVLayer(kLayer: KLayer, spacer: Spacer) -> VLayerProtocol
}

protocol VLayerProtocol {
    var kLayer: KLayer { get }
    var spacer: Spacer { get }

    func drawConnections(to upperLayer: VLayerProtocol)
    func drawNeurons()
}

extension VGridProtocol {
    func displayGrid(_ sensoryInputs: KLayer) { displayNet(sensoryInputs, kNet) }

    func displayNet(_ sensoryInputs: KLayer, _ kNet: KNet) {
        displayLayers(sensoryInputs, kNet.layers)
    }

    func displayLayers(_ sensoryInput: KLayer, _ kLayers: [KLayer]) {
        var iter = kLayers.makeIterator()
        let prime = iter.next()!

        var spacer = Spacer(netcam: gameScene, layersCount: kLayers.count)
        spacer.setDefaultCNeurons(prime.neurons.count)
        spacer.forSenseLayer = true

        var upperLayer = makeVLayer(kLayer: sensoryInput, spacer: spacer)
        upperLayer.drawNeurons()

        // Changes only the local copy, not the one we passed into
        // the upperLayer above.
        spacer.forSenseLayer = false

        kLayers.forEach {
            let lowerLayer = makeVLayer(kLayer: $0, spacer: spacer)
            lowerLayer.drawConnections(to: upperLayer)
            lowerLayer.drawNeurons()
            upperLayer = lowerLayer
        }
    }
}

struct VGrid: VGridProtocol {
    var gameScene: GameScene
    var labelBackground: SKShapeNode!
    var kNet: KNet
    var spacer: Spacer!
    var vBrainSceneSize: CGSize
    var vNeurons = [SKShapeNode]()

    init(gameScene: GameScene, kNet: KNet, sceneSize: CGSize) {
        self.gameScene = gameScene
        self.kNet = kNet
        self.vBrainSceneSize = sceneSize
    }

    func makeVLayer(kLayer: KLayer, spacer: Spacer) -> VLayerProtocol {
        return VGLayer(netcam: gameScene, kLayer: kLayer, spacer: spacer)
    }
}

struct VGNet {
    let layers: [VGLayer]

    init(_ layers: [VGLayer]) { self.layers = layers }

}

struct VGLayer: VLayerProtocol {
    weak var gameScene: GameScene!
    let kLayer: KLayer
    let spacer: Spacer

    init(netcam: GameScene, kLayer: KLayer, spacer: Spacer) {
        self.gameScene = netcam; self.kLayer = kLayer; self.spacer = spacer
    }

    func drawConnection(from: KIdentifier, to: KIdentifier, with upperLayerSpacer: Spacer) {
        let start = spacer.getPosition(xSS: from.myID, ySS: from.parentID)
        let end = upperLayerSpacer.getPosition(xSS: to.myID, ySS: to.parentID)

        print("from \(start) to \(end)")

        let linePath = CGMutablePath()

        linePath.move(to: start)
        linePath.addLine(to: end)

        let line = SKShapeNode(path: linePath)

        line.strokeColor = .green
        gameScene.addChild(line)
    }

    func drawConnections(to upperLayer: VLayerProtocol) {
        kLayer.neurons.compactMap({
            neuron in neuron.relay
        }).forEach { relay in
            var uniqueIDs = Set<KIdentifier>()

            relay.inputRelays.forEach { inputRelay in
                uniqueIDs.insert(inputRelay.id)
            }

            print("uid \(uniqueIDs)")

            uniqueIDs.forEach { inputRelayID in
                drawConnection(from: relay.id, to: inputRelayID, with: upperLayer.spacer)
            }
        }
    }

    func drawNeurons() {
        kLayer.neurons.forEach { neuron in
            let vNeuron = SKShapeNode(circleOfRadius: 10)

            vNeuron.fillColor = spacer.forSenseLayer ? .orange : .blue
            vNeuron.position = spacer.getPosition(xSS: neuron.id.myID, ySS: neuron.id.parentID)
            vNeuron.zPosition = 1.0
            gameScene.addChild(vNeuron)
        }
    }
}

struct VGNeuron {

}
#endif
