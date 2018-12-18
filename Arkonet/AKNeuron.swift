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

typealias RelayAnchor = (neuron: AKNeuron, relay: NeuronRelay?)

class NeuronRelay {
    let relayID: Int
    let layerID: Int

    var output: Double = 0.0
    var inputs = [RelayAnchor]()

    init(_ layerID: Int, _ relayID: Int) { self.layerID = layerID; self.relayID = relayID }
    deinit {
//        print("Relay(\(layerID):\(relayID)) destruct")
    }
}

class AKNeuron: CustomStringConvertible, LoopIterable {

    let activators: [Bool]
    let bias: Double
    let layerID: Int
    weak var loopIterableSelf: AKNeuron?
    let neuronID: Int
    var weights: [Int : Double]
    let weightDoublets: [ValueDoublet]

    // A neuron never owns its relay. The layer that created
    // the neuron temporarily holds the relay, until the whole
    // grid is set up. then the layer releases it, and the
    // only owner(s) will be the client(s) of the neuron. If
    // it has no owners, it will destruct, causing a chain
    // reaction, potentially all the way up.
    weak var relay: NeuronRelay?

    var description: String {
        var relayDisplay = "<released>"
        if let r = relay { relayDisplay = "\(r.relayID)" }
        return "AKNeuron(\(layerID):\(neuronID))(\(relayDisplay))" }

    init(_ xNeuron: Translators.Neuron, _ layerID: Int, _ neuronID: Int) {
        self.neuronID = neuronID
        self.layerID = layerID
        self.weights = [:]
        self.weightDoublets = xNeuron.weights
        self.bias = xNeuron.bias
        self.activators = xNeuron.activators
        self.loopIterableSelf = self
    }

    // Client neuron takes ownership of the relay. If all the
    // clients go away, the relay does too, and so does the neuron,
    // because the relay is the final owner.
    func connectToOutput(of neuron: AKNeuron, weight: Double) {
        relay<!>.inputs.append(RelayAnchor(neuron, neuron.relay<!>))
        weights[neuron.neuronID] = weight
    }

    func driveSensoryInput(_ input: Double) { relay<!>.output = input }

    func driveSignal() {
        for (inputNeuron, anchorRelay_) in relay<!>.inputs {
            guard let anchorRelay = anchorRelay_ else { continue }
            guard let inputRelay = inputNeuron.relay else { preconditionFailure() }
            guard let weight = weights[inputNeuron.neuronID] else { preconditionFailure() }

            anchorRelay.output += weight * inputRelay.output
//            print("\(self)(\(anchorRelay.relayID)) reads \(inputRelay.output) from \(inputNeuron)")
        }

        guard let r = self.relay else { preconditionFailure() }
        r.output = relay<!>.inputs.reduce(bias, {
            subtotal, inputSource in subtotal + inputSource.relay<!>.output
        })
    }

    func relaySignal(from upperLayer: AKLayer) {
        let fIter = ForwardLoopIterator(upperLayer.neurons, min(neuronID, upperLayer.count - 1))
        let rIter = ReverseLoopIterator(upperLayer.neurons, min(neuronID, upperLayer.count - 1))

        zip(activators, weightDoublets).forEach { activator, weightDoublet in
            let sourceNeuron: AKNeuron = activator ? skipDeadNeurons(fIter) : skipDeadNeurons(rIter)
            connectToOutput(of: sourceNeuron, weight: weightDoublet.value)
        }
    }

    func skipDeadNeurons(_ iter: LoopIterator<[AKNeuron]>) -> AKNeuron {
        repeat {

            let neuron = iter.compactNext()
            if neuron.relay == nil { continue }
            return neuron

        } while true
    }
}
