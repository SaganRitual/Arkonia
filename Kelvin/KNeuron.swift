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
#if SIGNAL_GRID_DIAGNOSTICS
import Foundation

class KNeuron: KIdentifiable, LoopIterable {
    let activator: AFn.FunctionName
    let bias: Double
    var downConnectors: [Int]
    let id: KIdentifier
    var inputs: [Double]!
    weak var loopIterableSelf: KNeuron?
    weak var relay: KSignalRelay?
    var upConnectors: [UpConnector]
    var weights = [Double]()

    var description: String { return id.description + ", \(upConnectors), \(downConnectors)" }

    init(_ id: KIdentifier) {
        self.id = id
        self.activator = AFn.FunctionName.boundidentity
        self.bias = 0.0
        self.downConnectors = []
        self.inputs = []
        self.upConnectors = []
        loopIterableSelf = self
    }

    init(_ id: KIdentifier, activator: AFn.FunctionName, bias: Double, downConnectors: [Int], upConnectors: [UpConnector]) {
        self.id = id
        self.activator = activator
        self.bias = bias
        self.downConnectors = downConnectors
        self.upConnectors = upConnectors
        loopIterableSelf = self
    }
}

extension KNeuron {
    static func makeNeuron(_ family: KIdentifier, _ me: Int, _ tNeuron: TNeuron) -> KNeuron {
        let id = family.add(me, as: .neuron)
        return KNeuron(
            id, activator: tNeuron.activator, bias: tNeuron.bias,
            downConnectors: tNeuron.downConnectors, upConnectors: tNeuron.upConnectors
        )
    }

    // For sensory layer and motor layer.
    static func makeNeuron(_ family: KIdentifier, _ me: Int) -> KNeuron {
        let id = family.add(me, as: .neuron)
        return KNeuron(id)
    }
}

extension KNeuron {
    func connect(to upperLayer: KLayer) {
        let connector = KConnector(self)
        let targetNeurons = connector.selectOutputs(from: upperLayer)

        relay?.connect(to: targetNeurons, in: upperLayer)
    }

    func driveSignal() {
        guard let relay = relay else { preconditionFailure() }

        let weighted: [Double] = zip(relay.inputRelays, upConnectors).compactMap {
            (pair: (KSignalRelay, UpConnector)) -> Double? in let (relay, connector) = pair
            return relay.output * connector.weight
        }

        relay.output = weighted.reduce(bias, +)
    }

    func driveSignal(from upperLayer: [KSignalRelay]) {
        let weighted: [Double] = zip(upperLayer, upConnectors).map {
            (pair: (KSignalRelay, UpConnector)) -> Double in
            let (relay, connector) = pair
            return relay.output * connector.weight
        }

        relay?.output = weighted.reduce(bias, +)
    }
}
#endif
