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

/**
 Builds the grid and drives the signal downward--the virtual signal, of
 course. This is all for display purposes.
 */
class USignalDriver {
    private var signals = [WeightedSignalProtocol]()
    private var lowerLayer: ULayer!
    private var motorLayer: ULayer!
    private var senseLayer: ULayer!
    private var upperLayer: ULayer!
    private var uNet: UNet
    private let fNet: FNet

    init(fNet: FNet, uNet: UNet) {
        self.fNet = fNet
        self.uNet = uNet
    }

    @discardableResult
    private func addLayer(role: ULayer.LayerRole, layerSSInGrid: Int) -> ULayer {
        upperLayer = lowerLayer
        lowerLayer = uNet.addLayer(layerRole: role, layerSSInGrid: layerSSInGrid)
        return lowerLayer
    }

    func drive() -> UNet {
        stimulus()

        (0..<fNet.layers.count).forEach {
            pullSignalFromUpper()
            addLayer(role: .hiddenLayer, layerSSInGrid: $0)
            pushSignalToLower(cNeurons: fNet.layers[$0].neurons.count)
        }

        response()

        return uNet // For chaining
    }

    func makeWeightedSignal(signalSource: VNeuron, weight: Double) -> WeightedSignalProtocol {
        preconditionFailure("Subclasses must implement this")
    }

    // Everyone below the sense layer pulls the signal down
    // Everyone in the middle does both: pull first, then push
    // Everyone above the motor layer pushes the signal down
    private func pullSignalFromUpper() {
        signals = lowerLayer.neurons.map { freckle in let heckle = freckle as! VNeuron
            return makeWeightedSignal(signalSource: heckle, weight: 1.066)
        }
    }

    // Everyone below the sense layer pulls the signal down
    // Everyone in the middle does both: pull first, then push
    // Everyone above the motor layer pushes the signal down
    private func pushSignalToLower(cNeurons: Int) {
        (0..<cNeurons).forEach { _ in
            lowerLayer.addNeuron(bias: 42.42, signals: signals, output: 24.24)
        }
    }

    private func response() {
        upperLayer = lowerLayer
        pullSignalFromUpper()
        motorLayer = addLayer(role: .motorLayer, layerSSInGrid: ArkonCentralDark.isMotorLayer)
        pushSignalToLower(cNeurons: fNet.cMotorNeurons)
    }

    private func stimulus() {
        senseLayer = addLayer(role: .senseLayer, layerSSInGrid: ArkonCentralDark.isSenseLayer)
        pushSignalToLower(cNeurons: fNet.cSenseNeurons)
        upperLayer = senseLayer
    }

}
