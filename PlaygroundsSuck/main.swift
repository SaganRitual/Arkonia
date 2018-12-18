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

class AKNeuron: CustomStringConvertible {
    // A neuron never owns its relay. The layer that created
    // the neuron temporarily holds the relay, until the whole
    // grid is set up. then the layer releases it, and the
    // only owner(s) will be the client(s) of the neuron.
    var inputs: [RelayAnchor]
    let layerID: Int
    let neuronID: Int
    var weights: [Int : Double]
    let bias: Double

    weak var relay: NeuronRelay?

    var description: String {
        var relayDisplay = "<released>"
        if let r = relay { relayDisplay = "\(r.relayID)" }
        return "AKNeuron(\(layerID):\(neuronID))(\(relayDisplay))" }

    init(_ relay: NeuronRelay, _ layerID: Int, _ neuronID: Int) {
        self.relay = relay; self.neuronID = neuronID
        self.layerID = layerID
        inputs = []; weights = [:]; bias = 24.24
    }

    // Client neuron takes ownership of the relay. If all the
    // clients go away, the relay does too, and so does the neuron,
    // because the relay is the final owner.
    func connectToOutput(of neuron: AKNeuron, weight: Double) {
        inputs.append(RelayAnchor(neuron, self.relay!))
        weights[neuron.neuronID] = weight
    }

    func driveSensoryInput(_ input: Double) { relay!.output = input }

    func driveSignal() {
        for (inputNeuron, anchorRelay_) in inputs {
            guard let anchorRelay = anchorRelay_ else { continue }
            guard let inputRelay = inputNeuron.relay else { preconditionFailure() }
            guard let weight = weights[inputNeuron.neuronID] else { preconditionFailure() }

            anchorRelay.output += weight * inputRelay.output
            print("\(self)(\(anchorRelay.relayID)) reads \(inputRelay.output) from \(inputNeuron)")
        }

        guard let r = self.relay else { preconditionFailure() }
        r.output = inputs.reduce(bias, { subtotal, inputSource in subtotal + inputSource.relay!.output })
    }
}

class NeuronRelay {
    let relayID: Int
    let layerID: Int

    var output: Double = 0.0

    init(_ layerID: Int, _ relayID: Int) { self.layerID = layerID; self.relayID = relayID }

//    deinit { print("~NeuronRelay(\(layerID):\(relayID))") }
}

class AKLayer {
    let layerID: Int
    var neurons = [AKNeuron]()
    var relays = [NeuronRelay?]()

    var relayID = 0
    var neuronID = 0

    init(_ xLayer: Translators.Layer, _ idNumber: Int) {
        self.layerID = idNumber

        neurons = xLayer.neurons.map { xNeuron in
            defer { neuronID += 1 }
            let n = AKNeuron(xNeuron, layerID, neuronID)
            return n
        }

        relays = neurons.map { neuron in
            defer { relayID += 1 }
            let newRelay = NeuronRelay(layerID, relayID)
            neuron.relay = newRelay
            return neuron.relay
        }
    }

    func driveSensoryInputs(_ inputs: [Double]) {
        zip(neurons, inputs).forEach {
            (z) in let (neuron, input) = z; neuron.driveSensoryInput(input)
        }
    }

    func driveSignal() {
        neurons.forEach { $0.driveSignal() }
    }

    func scenario() {
        neurons.remove(at: 5)
    }
}

class AKNet {
    var arkonID: Int?
    var layers = [AKLayer]()

    init(_ xLayers: [Translators.Layer]) {
        layers = xLayers.enumerated().map { (arkonID, xLayer) in AKLayer(xLayer, arkonID) }
    }

    func attachRelay(_ sink: (y: Int, x: Int), to source: (y: Int, x: Int)) {
        let sourceNeuron = layers[source.y].neurons[source.x]
        let sinkNeuron = layers[sink.y].neurons[sink.x]

        sinkNeuron.connectToOutput(of: sourceNeuron, weight: 42.42)
    }

    func driveSignal(_ sensoryInputs: [Double]) -> [Double] {
        var iter = layers.makeIterator()

        var upperLayer = iter.next()!
        upperLayer.driveSensoryInputs(sensoryInputs)

        for lowerLayer in iter {
            lowerLayer.driveSignal()
            upperLayer.relays.removeAll()
            upperLayer = lowerLayer
        }

        return layers.last!.relays.compactMap { r in if let relay = r { return relay.output } else { return nil } }
    }

    func showOutputs() {
        print("Reading \(layers.last!.relays.count) output signals")
        layers.last!.relays.forEach { if let has = $0 { print(has.output) } else { print("nil") } }
    }
}

let net = AKNet()

net.attachRelay((1, 1), to: (0, 0))
net.attachRelay((2, 2), to: (1, 1))
net.attachRelay((3, 3), to: (2, 2))
net.attachRelay((4, 4), to: (3, 3))
net.attachRelay((5, 5), to: (4, 4))
net.attachRelay((6, 6), to: (5, 5))
net.attachRelay((7, 7), to: (6, 6))
net.attachRelay((8, 8), to: (7, 7))
net.attachRelay((9, 9), to: (8, 8))

var anchors = net.layers.last!.neurons.map { n in n.relay! }
net.driveSignal([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0])
net.showOutputs()

//
//var relay: NeuronRelay? = layers.last!.neurons[3].attachRelay()
//layers.last!.neurons[3].inputs.append(relay!)
//relay = nil
//
////_ = layers.last!.relays.removeAll()
//while !layers.last!.relays.isEmpty { _ = layers.last!.relays.removeLast() }
//

print("Done")
