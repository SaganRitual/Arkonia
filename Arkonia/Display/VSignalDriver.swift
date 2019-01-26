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
class VSignalDriver {
    private var inputSources = [VInputSource]()
    private var lowerLayer: VLayer!
    private var motorLayer: VLayer!
    private var senseLayer: VLayer!
    private var upperLayer: VLayer!
    private var vNet: VNet
    private let tNet: TNet

    init(tNet: TNet) {
        self.tNet = tNet
        self.vNet = VNet(id: KIdentifier("Crashnburn", 0))
    }

    @discardableResult
    private func addLayer(role: VLayer.LayerRole, layerSSInGrid: Int) -> VLayer {
        upperLayer = lowerLayer
        lowerLayer = vNet.addLayer(layerRole: role, layerSSInGrid: layerSSInGrid)
        return lowerLayer
    }

    func drive() -> VNet {
        stimulus()

        (0..<tNet.layers.count).forEach {
            pullSignalFromUpper()
            addLayer(role: .hiddenLayer, layerSSInGrid: $0)
            pushSignalToLower(cNeurons: tNet.layers[$0].neurons.count)
        }

        response()

        return vNet // For chaining
    }

    // Everyone below the sense layer pulls the signal down
    // Everyone in the middle does both: pull first, then push
    // Everyone above the motor layer pushes the signal down
    private func pullSignalFromUpper() {
        inputSources = lowerLayer.neurons.map { VInputSource(source: $0, weight: 1.066) }
    }

    // Everyone below the sense layer pulls the signal down
    // Everyone in the middle does both: pull first, then push
    // Everyone above the motor layer pushes the signal down
    private func pushSignalToLower(cNeurons: Int) {
        (0..<cNeurons).forEach { _ in
            lowerLayer.addNeuron(bias: 42.42, inputSources: inputSources, output: 24.24)
        }
    }

    private func response() {
        upperLayer = lowerLayer
        pullSignalFromUpper()
        motorLayer = addLayer(role: .motorLayer, layerSSInGrid: ArkonCentralDark.isMotorLayer)
        pushSignalToLower(cNeurons: tNet.cMotorNeurons)
    }

    private func stimulus() {
        senseLayer = addLayer(role: .senseLayer, layerSSInGrid: ArkonCentralDark.isSenseLayer)
        pushSignalToLower(cNeurons: tNet.cSenseNeurons)
        upperLayer = senseLayer
    }

}
