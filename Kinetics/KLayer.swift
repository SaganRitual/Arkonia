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

class KLayer: KIdentifiable {
    var description: String { return id.description }
    let id: KIdentifier
    var neurons: [KNeuron]
    var signalRelays: [KSignalRelay]

    private init(_ id: KIdentifier, _ neurons: [KNeuron], _ signalRelays: [KSignalRelay]) {
        self.id = id; self.neurons = neurons; self.signalRelays = signalRelays
    }

    deinit {
        decoupleFromGrid()
        neurons.compactMap { $0.relay }.forEach { $0.releaseInputs() }
    }
}

extension KLayer {
    func connect(to upperLayer: KLayer) { for neuron in neurons { neuron.connect(to: upperLayer) } }

    func decoupleFromGrid() {
        while !signalRelays.isEmpty { signalRelays.removeLast() }
    }

    func driveSignal() {
        for neuron in neurons {
            neuron.driveSignal(isMotorLayer: id.myID == ArkonCentralDark.isMotorLayer.rawValue)
        }
    }

    static func makeLayer(_ myFullID: KIdentifier, _ layerType: KIdentifier.KType, _ cNeurons: Int)
        -> KLayer
    {
        let signalRelays: [KSignalRelay] = (0..<cNeurons).map {
            let relay = KSignalRelay.makeRelay(myFullID, $0)
            relay.overriddenState = layerType == .senseLayer || layerType == .motorLayer
            return relay
        }

        let neurons: [KNeuron] = signalRelays.enumerated().map { idNumber, relay in
            let newNeuron = KNeuron.makeNeuron(myFullID, idNumber)
            newNeuron.relay = relay
//            relay.breaker = relay
            return newNeuron
        }

        return KLayer(myFullID, neurons, signalRelays)
    }

    static func makeLayer(_ newLayerID: KIdentifier, _ fLayer: FLayer) -> KLayer {
        let signalRelays = (0..<fLayer.count).map { KSignalRelay.makeRelay(newLayerID, $0) }

        var fIter = fLayer.neurons.makeIterator()
        let neurons: [KNeuron] = signalRelays.enumerated().map { neuronIDNumber, relay in
            let newNeuronID = newLayerID.add(neuronIDNumber, as: .neuron)
            let fNeuron = nok(fIter.next())
            let newNeuron = KNeuron.makeNeuron(newNeuronID, fNeuron)
            newNeuron.relay = relay
            return newNeuron
        }

        return KLayer(newLayerID, neurons, signalRelays)
    }

    func reverseConnect(_ lastHiddenLayer: KLayer) {
        for upperNeuron in lastHiddenLayer.neurons {
            while !upperNeuron.downConnectors.isEmpty {
                let connector = upperNeuron.downConnectors.removeLast()
                let outputNeuronSS = connector %% self.neurons.count
                let outputNeuron = self.neurons[outputNeuronSS]

                outputNeuron.relay!.inputRelays.append(upperNeuron.relay!)
            }
        }
    }
}
