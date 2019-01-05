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

struct KNetDimensions {
    static let cLayers = 4
    static let cMotorOutputs = 3
    static let cNeurons = 2
    static let cSensoryInputs = 5
}

#if SIGNAL_GRID_DIAGNOSTICS
struct KDriver  {
    var motorLayer: KLayer
    let motorLayerID: KIdentifier
    var motorOutputs: [Double]!
    let senseLayer: KLayer
    let senseLayerID: KIdentifier
    let sensoryInputs = [1.0, 1.0, 1.0, 1.0, 1.0]
    let theNet: KNet

    init() {
        theNet = KNet.makeNet(0, cLayers: KNetDimensions.cLayers)
        senseLayerID = KIdentifier("Senses", [], -1)
        senseLayer = KLayer.makeLayer(senseLayerID, 0, cNeurons: KNetDimensions.cSensoryInputs)
        motorLayerID = KIdentifier("Senses", [], -2)
        motorLayer = KLayer.makeLayer(motorLayerID, 0, cNeurons: KNetDimensions.cMotorOutputs)
    }

    func drive() {
        senseLayer.signalRelays.enumerated().forEach { whichInput, relay in
            relay.overrideState(operational: true)
            relay.output = sensoryInputs[whichInput]
        }

        theNet.driveSignal(senseLayer, motorLayer)
        print("Releasing output layer relays")

        let gs = GameScene.gameScene!
        gs.makeVGrid(theNet)

        theNet.gridAnchors.forEach { print($0.output) }
        print("All done")
    }

    func transferGridAnchors() -> [KSignalRelay] {
        defer { theNet.gridAnchors.removeAll() }
        return theNet.gridAnchors
    }
}

struct GridXY {
    let x: Int, y: Int
    weak var relay: KSignalRelay?

    init(_ x: Int, _ y: Int) { self.x = x; self.y = y }
}

struct ConnectionSpec {
    var weights: [GridXY]
}

struct WeightSpec {
    var weights: [Double]
}

let mockWeights: [[WeightSpec]] = [
    [
        WeightSpec(weights: [1.0, 1.0]),
        WeightSpec(weights: [1.0, 1.0]),
        WeightSpec(weights: [1.0]),
        WeightSpec(weights: [1.0]),
        WeightSpec(weights: [1.0]),
    ], [
        WeightSpec(weights: [1.0]),
        WeightSpec(weights: [1.0, 1.0]),
        WeightSpec(weights: [1.0, 1.1]),
        WeightSpec(weights: [1.0]),
        WeightSpec(weights: [1.0]),
    ], [
        WeightSpec(weights: [1.0]),
        WeightSpec(weights: [1.0]),
        WeightSpec(weights: [1.0]),
        WeightSpec(weights: [1.0]),
        WeightSpec(weights: [1.0]),
    ], [
        WeightSpec(weights: [1.0]),
        WeightSpec(weights: [1.0]),
        WeightSpec(weights: [1.0]),
        WeightSpec(weights: [1.0]),
        WeightSpec(weights: [1.0]),
    ], [
        WeightSpec(weights: [1.0]),
        WeightSpec(weights: [1.0]),
        WeightSpec(weights: [1.0]),
        WeightSpec(weights: [1.0]),
        WeightSpec(weights: [1.0]),
    ],
]
#endif
