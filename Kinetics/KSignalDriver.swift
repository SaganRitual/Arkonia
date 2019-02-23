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

class KSignalDriver  {
    static var fishNumber = 0

    var motorLayer: KLayer
    let motorLayerID: KIdentifier
    var motorOutputs: [Double]!
    let senseLayer: KLayer
    let senseLayerID: KIdentifier
    let kNet: KNet

    init(idNumber: Int, fNet: FNet) {
        defer { KSignalDriver.fishNumber += 1 }

        let kNet = KNet.makeNet(idNumber, fNet)

        senseLayerID = kNet.id.add(KIdentifier.KType.senseLayer.rawValue, as: .senseLayer)
        senseLayer = KLayer.makeLayer(
            senseLayerID, KIdentifier.KType.senseLayer,
            ArkonCentralDark.selectionControls.cSenseNeurons
        )

        motorLayerID = kNet.id.add(KIdentifier.KType.motorLayer.rawValue, as: .motorLayer)
        motorLayer = KLayer.makeLayer(
            motorLayerID, KIdentifier.KType.motorLayer,
            ArkonCentralDark.selectionControls.cMotorNeurons
        )

        self.kNet = kNet
    }

    func drive(sensoryInputs: [Double]) -> Bool {
        for (sensoryInput, relay) in zip(sensoryInputs, senseLayer.signalRelays) {
            relay.overrideState(operational: true)
            relay.output = sensoryInput
        }

        let arkonSurvived = kNet.driveSignal(senseLayer, motorLayer)
        if !arkonSurvived { return false }

        motorOutputs = kNet.motorLayer.neurons.map { return $0.relay!.output }

        return true
    }
}
