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

class VisualizerTest : SKScene {
    private var workItem: DispatchWorkItem?

    private var sprite = SKSpriteNode()

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

    override func didChangeSize(_ oldSize: CGSize) {
        guard ArkonCentral.visualizer == nil else { return }

        ArkonCentral.visualizer = self

        self.workItem = DispatchWorkItem { [weak self] in
            guard let elf = self else { preconditionFailure("Stop touching your elf") }
            VisualizerSmokeTest(elf).test()
            elf.workItem = nil
        }

        DispatchQueue.global(qos: .background).async(execute: self.workItem!)
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

class VisualizerSmokeTest {
    var odometer = [1, 1, 1]
    weak var visualizer: VisualizerTest?

    init(_ visualizer: VisualizerTest) {
        self.visualizer = visualizer
        self.visualizer?.setUpdateCallback( visualize )
    }

    func rollOdometer(rollAt: Int) {
        var carry = 1

        odometer = odometer.map {
            let next = carry + $0
            carry = next / (rollAt + 1)

            let maybeZero = next % (rollAt + 1)
            return maybeZero == 0 ? 1 : maybeZero
        }

        if carry != 0 { odometer.append(1) }
    }

    func stitch(net: VNet, upperLayer: VLayer, ssLowerLayer: Int, layerRole: VLayer.LayerRole)
        -> (VLayer, [VInputSource])
    {
        let lowerLayer = net.addLayer(layerRole: layerRole, layerSSInGrid: ssLowerLayer)
        let inputSources = upperLayer.neurons.map { VInputSource(source: $0, weight: 1.066) }

        return (lowerLayer, inputSources)
    }

    func test() { visualizer!.semaphore.wait() }

    func visualize() {
        visualize(cSenseNeurons: odometer[0], cMotorNeurons: odometer[1],
                  hiddenLayers: odometer[2...])

        rollOdometer(rollAt: 5)
    }

    func visualize(cSenseNeurons: Int, cMotorNeurons: Int, hiddenLayers: ArraySlice<Int>) {
        guard let visualizer = self.visualizer else { preconditionFailure("or here maybe") }

        let netID = KIdentifier("Smoker", 0)
        let net = VNet(id: netID, netcam: visualizer)

        let senseLayer = net.addLayer(layerRole: .senseLayer, layerSSInGrid: -1)
        (0..<cSenseNeurons).forEach { _ in
            _ = senseLayer.addNeuron(bias: 42.42, inputSources: [], output: 24.24)
        }

        var upperLayer = senseLayer

        hiddenLayers.enumerated().forEach { (ssLowerLayer, cNeurons) in
            let (lowerLayer, inputSources) = stitch(
                net: net, upperLayer: upperLayer, ssLowerLayer: ssLowerLayer,
                layerRole: .hiddenLayer
            )

            (0..<cNeurons).forEach { _ in
                lowerLayer.addNeuron(bias: 42.42, inputSources: inputSources, output: 24.24)
            }

            upperLayer = lowerLayer
        }

//        let motorLayer = net.addLayer(layerRole: .motorLayer, layerSSInGrid: -2)
        let (motorLayer, inputSources) = stitch(
            net: net, upperLayer: upperLayer, ssLowerLayer: -2, layerRole: .motorLayer
        )

        (0..<cMotorNeurons).forEach { _ in
            motorLayer.addNeuron(bias: 42.42, inputSources: inputSources, output: 24.24)
        }

        net.visualize()
    }

}
