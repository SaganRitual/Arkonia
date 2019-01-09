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

struct VGrid {
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

    func makeVLayer(kLayer: KLayer, spacer: Spacer) -> VLayer {
        return VLayer(netcam: gameScene, kLayer: kLayer, spacer: spacer)
    }
}

struct VGNet {
    let layers: [VLayer]

    init(_ layers: [VLayer]) { self.layers = layers }

}

extension VGrid {
    func displayGrid(_ senseLayer: KLayer, _ motorLayer: KLayer) { displayNet(senseLayer, kNet, motorLayer) }

    func displayNet(_ senseLayer: KLayer, _ kNet: KNet, _ motorLayer: KLayer) {
        displayLayers(senseLayer, kNet.layers, motorLayer)
    }

//    func foo() {
//
//        let nk = kLayer
//        nk.neurons = kLayer.neurons.compactMap { $0.relay == nil ? nil : $0 }
//
//        var inputSS = 0
//        var serveSS = 0
//
//        // With profound gratitude to this guy:
//        // https://stackoverflow.com/users/5230311/tj3n
//        // https://stackoverflow.com/a/38455935/1610473
//        //
//        compactGrid = kLayer.neurons.reduce([Int : Int]()) { (dictionary, neuron) in
//            if neuron.relay == nil { return dictionary }
//
//            defer { serveSS += 1 }
//            var d = dictionary; d[inputSS] = serveSS; return d
//        }
//
//        self.kLayer = nk
//        print("VLayer for \(kLayer) real = \(kLayer.neurons.count), virtual = \(self.kLayer.neurons.count)")
//    }

    func compactNeurons(for kLayer: KLayer) -> [Int : Int] {
        var inputSS = 0
        var serveSS = 0

        return kLayer.neurons.reduce(into: [Int : Int]()) { (dictionary, neuron) in
            defer { inputSS += 1 }
            if neuron.relay == nil { return }

            defer { serveSS += 1 }
            dictionary[inputSS] = serveSS
        }
    }

    func displayLayers(_ senseLayer: KLayer, _ kLayers: [KLayer], _ motorLayer: KLayer) {
        var spacer = Spacer(netcam: gameScene, layersCount: kLayers.count)
        spacer.setHorizontalSpacing(compactNeurons(for: senseLayer))

        spacer.layerType = .sensoryInputs

        var upperLayer = makeVLayer(kLayer: senseLayer, spacer: spacer)

        _ = upperLayer.drawNeurons()
        //        var nodeLayer = upperLayer.drawNeurons()
        //        upperLayer.drawParameters(on: nodeLayer, isSenseLayer: true)

        // Changes only the local copy, not the one we passed into
        // the upperLayer above.
        spacer.layerType = .hidden

        kLayers.forEach {
            spacer.setHorizontalSpacing(compactNeurons(for: $0))

            let lowerLayer = makeVLayer(kLayer: $0, spacer: spacer)
            lowerLayer.drawConnections(to: upperLayer)

            _ = lowerLayer.drawNeurons()
            //            nodeLayer = lowerLayer.drawNeurons()
            //            lowerLayer.drawParameters(on: nodeLayer, isSenseLayer: false)

            upperLayer = lowerLayer
        }

        spacer.layerType = .motorOutputs
        spacer.setHorizontalSpacing(compactNeurons(for: motorLayer))

        let bottomLayer = makeVLayer(kLayer: motorLayer, spacer: spacer)
        bottomLayer.drawConnections(to: upperLayer)
        _ = bottomLayer.drawNeurons()
    }
}
