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
    let vNet: VNet
    let cSenseNeurons = ArkonCentral.selectionControls.cSenseNeurons

    private var inputSources = [VInputSource]()
    private var lowerLayer: VLayer!
    private var motorLayer: VLayer!
    private var senseLayer: VLayer!
    private var upperLayer: VLayer!

    init(_ vNet: VNet) { self.vNet = vNet }

    @discardableResult
    private func addLayer(role: VLayer.LayerRole, layerSSInGrid: Int) -> VLayer {
        upperLayer = lowerLayer
        lowerLayer = vNet.addLayer(layerRole: role, layerSSInGrid: layerSSInGrid)
        return lowerLayer
    }

    func driveSignal(cSenseNeurons: Int, cMotorNeurons: Int,
                     hiddenLayerNeuronCounts: ArraySlice<Int>)
    {
        stimulus(cSenseNeurons)

        hiddenLayerNeuronCounts.enumerated().forEach { (ssLowerLayer, cNeuronsThisLayer) in
            pullSignalFromTop()
            addLayer(role: .hiddenLayer, layerSSInGrid: ssLowerLayer)
            pushSignalToBottom(cNeurons: cNeuronsThisLayer)
        }

        response(cMotorNeurons)
    }

    // Everyone below the sense layer pulls the signal down
    // Everyone in the middle does both: pull first, then push
    // Everyone above the motor layer pushes the signal down
    private func pullSignalFromTop() {
        inputSources = lowerLayer.neurons.map { VInputSource(source: $0, weight: 1.066) }
    }

    // Everyone below the sense layer pulls the signal down
    // Everyone in the middle does both: pull first, then push
    // Everyone above the motor layer pushes the signal down
    private func pushSignalToBottom(cNeurons: Int) {
        (0..<cNeurons).forEach { _ in
            lowerLayer.addNeuron(bias: 42.42, inputSources: inputSources, output: 24.24)
        }
    }

    private func response(_ cMotorNeurons: Int) {
        upperLayer = lowerLayer
        pullSignalFromTop()
        motorLayer = addLayer(role: .motorLayer, layerSSInGrid: ArkonCentral.isMotorLayer)
        pushSignalToBottom(cNeurons: cMotorNeurons)
    }

    private func stimulus(_ cSenseNeurons: Int) {
        senseLayer = addLayer(role: .senseLayer, layerSSInGrid: ArkonCentral.isSenseLayer)
        pushSignalToBottom(cNeurons: cSenseNeurons)
        upperLayer = senseLayer
    }

}
