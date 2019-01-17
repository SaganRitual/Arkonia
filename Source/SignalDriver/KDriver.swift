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

class KDriver  {
    static var fishNumber = 0

    var motorLayer: KLayer
    let motorLayerID: KIdentifier
    var motorOutputs: [Double]!
    let senseLayer: KLayer
    let senseLayerID: KIdentifier
    let kNet: KNet

    init(tNet: TNet) {
        defer { KDriver.fishNumber += 1 }

        kNet = KNet.makeNet(KDriver.fishNumber, tNet: tNet)
        senseLayerID = KIdentifier("Sense", kNet.id.myID)
        senseLayer = KLayer.makeLayer(senseLayerID, KLayer.isSenseLayer, cNeurons: ArkonCentral.sel.cSenseNeurons)
        motorLayerID = KIdentifier("Motor", kNet.id.myID)
        motorLayer = KLayer.makeLayer(motorLayerID, KLayer.isMotorLayer, cNeurons: ArkonCentral.sel.cMotorNeurons)
    }

//    deinit {
//        print("~\(self)")
//    }

    func drive(sensoryInputs: [Double]) {
        senseLayer.signalRelays.enumerated().forEach { whichInput, relay in
            relay.overrideState(operational: true)
            relay.output = sensoryInputs[whichInput]
        }

        kNet.driveSignal(senseLayer, motorLayer)
//        print("Releasing output layer relays")

        motorOutputs = kNet.motorLayer.neurons.map { return $0.relay!.output }

//        kNet.gridAnchors.forEach { print($0.output) }
//        print("All done")
    }
}
