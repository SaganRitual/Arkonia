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

class KNeuron: KIdentifiable, LoopIterable {
    let activators = Array(repeatElement(true, count: cLayers))
    let bias = 0.0
    var description: String { return id.description }
    let id: KIdentifier
    var inputs: [Double]!
    weak var loopIterableSelf: KNeuron?
    weak var relay: KSignalRelay?
    let weights = Array(repeatElement(1.0, count: cLayers))

    init(_ id: KIdentifier) { self.id = id; loopIterableSelf = self }
}

extension KNeuron {
    static func makeNeuron(_ family: KIdentifier, _ me: Int) -> KNeuron {
        let id = family.add(me, as: .neuron)
        return KNeuron(id)
    }

    func connect(to upperLayer: KLayer) {
        let connector = KConnector(self)
        let targetNeurons = connector.selectOutputs(from: upperLayer)

        relay?.connect(to: targetNeurons, in: upperLayer)
    }

    // We're using dummy connection specs. When we get back to the land
    // of the living, the connection info will be based on the weights
    // that the receiving neuron got from its genes.
    func mockConnect(to upperLayer: KLayer) {
        guard let relay = relay else { preconditionFailure() }
        let neuronIDs = KConnectoid.getConnections(relay, to: upperLayer)
        relay.connect(to: neuronIDs, in: upperLayer)
        //        print("\(self) c\(inputRelays)")
    }

    func driveSignal() {
        guard let relay = relay else { preconditionFailure() }

        let weighted: [Double] = zip(relay.inputRelays, weights).compactMap {
            (pair: (KSignalRelay, Double)) -> Double? in
                let (relay, weight) = pair; return relay.output * weight
        }

        relay.output = weighted.reduce(bias, +)
//        print("\(self) output = \(relay.output)")
    }

    func driveSignal(from upperLayer: [KSignalRelay]) {
        let weighted: [Double] = zip(upperLayer, weights).map {
            (pair: (KSignalRelay, Double)) -> Double in
            let (relay, weight) = pair
//            print("\(self) input = \(relay.output) * \(weight) = \(relay.output * weight)")
            return relay.output * weight
        }

        relay?.output = weighted.reduce(bias, +)
//        print("\(self) output = \(relay?.output ?? -42.0)")
    }
}
