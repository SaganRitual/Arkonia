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

    var isTopLayer: Bool { return layerID == 0 }

    public func getReference() -> NeuronRelay {
//        print("+\(layerID):\(relayID) ", terminator: "")
//        print("+", terminator: "")
        return self
    }

    public static func makeNeuronRelay(_ layerID: Int, _ relayID: Int) -> NeuronRelay {
//        print("$", terminator: "")
//        print("$\(layerID):\(relayID) ", terminator: "")
        return NeuronRelay(layerID, relayID)
    }

    private init(_ layerID: Int, _ relayID: Int) {
        self.layerID = layerID; self.relayID = relayID
//        print("Relay(\(layerID):\(relayID)) init")
    }

    deinit {
//        print("-\(layerID):\(relayID) ", terminator: "")
//        print("-", terminator: "")
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
        return "AKNeuron(\(layerID):\(neuronID))(\(relayDisplay))"
    }

    init(_ xNeuron: Translators.Neuron, _ layerID: Int, _ neuronID: Int) {
        self.neuronID = neuronID
        self.layerID = layerID
        self.weights = [:]
        self.weightDoublets = xNeuron.weights
        self.bias = xNeuron.bias
        self.activators = xNeuron.activators
        self.loopIterableSelf = self
    }

    deinit { relay?.inputs.removeAll() }

    func connectToOutput(of neuron: AKNeuron, weight: Double) {
        let ra = RelayAnchor(neuron, neuron.relay<!>.getReference())
        relay<!>.inputs.append(ra)
//        print("c", terminator: "")
        weights[neuron.neuronID] = weight
    }

    func connectToOutputs(from upperLayer: AKLayer) -> Bool {
        let fIter = ForwardLoopIterator(upperLayer.neurons, min(neuronID, upperLayer.count - 1))
        let rIter = ReverseLoopIterator(upperLayer.neurons, min(neuronID, upperLayer.count - 1))

        for (activator, weightDoublet) in zip(activators, weightDoublets) {
            let iter = activator ? fIter : rIter
            guard let sourceNeuron = skipDeadNeurons(iter) else { print("!"); return false }

            //            print("\(self) connecting to \(sourceNeuron)")
            connectToOutput(of: sourceNeuron, weight: weightDoublet.value)
        }

        return true
    }

    func driveSensoryInput(_ input: Double) { relay?.output = input }

    func driveSignal() -> Bool {
        guard let relay = self.relay else { return false }

        if relay.inputs.isEmpty { return false }

        relay.output = relay.inputs.reduce(bias, {
            subtotal, inputSource in

            let r = inputSource.relay<!>
            return subtotal + r.output * self.weights[inputSource.neuron.neuronID]<!>
        })

        return true
    }

    func skipDeadNeurons(_ iter: LoopIterator<[AKNeuron]>) -> AKNeuron? {
        var boundsChecker = 0
        repeat {

            let neuron = iter.compactNext()
            guard let r = neuron.relay else { continue }
            if r.inputs.isEmpty && !r.isTopLayer { continue }

            boundsChecker += 1

            return neuron

        } while boundsChecker < iter.count

        return nil
    }
}
