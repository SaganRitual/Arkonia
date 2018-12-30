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

class AKPulse {
    weak var neuron: AKNeuron!
    let weight: Double

    init(_ neuron: AKNeuron, _ weight: Double) {
        self.neuron = neuron; self.weight = weight
    }
}

class AKNeuron: CustomStringConvertible, LoopIterable {

    let activators: [Bool]
    let bias: Double
    weak var gridScaffolding: K2GridScaffolding?
    let layerID: Int
    weak var loopIterableSelf: AKNeuron?
    let neuronID: Int
    var output = 0.0
    var pulses = [AKPulse]()
    var weights: [Int : [Double]]
    let weightDoublets: [ValueDoublet]

    var description: String {
        return "AKNeuron(\(layerID):\(neuronID))"
    }

    var isTopLayer: Bool { return layerID == 0 }

    init(_ xNeuron: Translators.Neuron, _ layerID: Int, _ neuronID: Int) {
        self.neuronID = neuronID
        self.layerID = layerID
        self.weights = [:]
        self.weightDoublets = xNeuron.weights
        self.bias = xNeuron.bias
        self.activators = xNeuron.activators
        self.loopIterableSelf = self

        K2SignalGrid.signalGrid.nextNeuron(neuronID)

        // Weak ref to grid so display can tell whether to draw lines
        gridScaffolding = K2SignalGrid.signalGrid.lowerLayer[neuronID]
    }

    func connectToOutput(of neuron: AKNeuron, weight: Double) {
        K2SignalGrid.signalGrid.attach(self.neuronID, to: neuron.neuronID)
        pulses.append(AKPulse(neuron, weight))
    }

    func connectToOutputs(from upperLayer: AKLayer) -> Bool {
        let fIter = ForwardLoopIterator(upperLayer.neurons, min(neuronID, upperLayer.count - 1))
        let rIter = ReverseLoopIterator(upperLayer.neurons, min(neuronID, upperLayer.count - 1))

        for (activator, weightDoublet) in zip(activators, weightDoublets) {
            let iter = activator ? fIter : rIter
            guard let sourceNeuron = skipDeadNeurons(iter) else { return false }

            connectToOutput(of: sourceNeuron, weight: weightDoublet.value)
        }

        return true
    }

    // Called only for the sense layer; all the others go by driveSignal()
    func driveSensoryInput(_ input: Double) { self.output = input }

    func driveSignal() -> Bool {
        guard isTopLayer || K2SignalGrid.signalGrid.hasInputs(neuronID) else { return false }

        output = pulses.reduce(bias) { subtotal, pulse in
            return subtotal + pulse.neuron.output * pulse.weight
        }

        return true
    }

    func skipDeadNeurons(_ iter: LoopIterator<[AKNeuron]>) -> AKNeuron? {
        var boundsChecker = 0
        repeat {

            defer { boundsChecker += 1 }

            let neuron = iter.compactNext()
            guard neuron.isTopLayer || K2SignalGrid.signalGrid.hasInputs(neuron.neuronID)
                else { continue }

            return neuron

        } while boundsChecker < iter.count

        return nil
    }
}
