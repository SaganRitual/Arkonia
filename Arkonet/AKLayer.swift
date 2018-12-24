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

class AKLayer {
    let layerID: Int
    var neurons = [AKNeuron]()
    var relays = [NeuronRelay?]()

    var relayID = 0
    var neuronID = 0

    var count: Int { return neurons.count }

    init(_ xLayer: Translators.Layer, _ idNumber: Int) {
        self.layerID = idNumber

        neurons = xLayer.neurons.map { xNeuron in
            defer { neuronID += 1 }
            let n = AKNeuron(xNeuron, layerID, neuronID)
            return n
        }

        relays = neurons.map { neuron in
            defer { relayID += 1 }
            let newRelay = NeuronRelay.makeNeuronRelay(layerID, relayID)
            neuron.relay = newRelay // weak ref
            return neuron.relay
        }
    }

    func driveSensoryInputs(_ inputs: [Double]) {
        for (neuron, input) in zip(neurons, inputs) {
            neuron.driveSensoryInput(input)
        }
    }

    func driveSignal(from upperLayer: AKLayer, _ establishConnections: Bool) -> AKLayer? {
        var signalPassed = false

        for neuron in neurons {
            if establishConnections {
                guard neuron.connectToOutputs(from: upperLayer) else { return nil }
            }

            guard neuron.driveSignal() else { continue }
            signalPassed = true
        }

        return signalPassed ? self : nil
    }
}
