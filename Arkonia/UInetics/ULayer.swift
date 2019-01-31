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
import SpriteKit

struct VWeightedSignal: SignalSourceProtocol, WeightedSignalProtocol {
    var signalSource: VNeuron
    var weight: Double

    // The output from a neuron is the raw signal
    // value from the neuron above. In some cases it's
    // easier to think of it as output, in others it's
    // easier as signal.
    var output: Double { return signalSource.output }
}

class ULayer: KIdentifiable, Equatable {
    enum LayerRole { case senseLayer, hiddenLayer, motorLayer }

    let id: KIdentifier
    var layerRole: ULayer.LayerRole
    var neurons = [UNeuron]()
    let layerSSInGrid: Int

    var debugDescription: String {
        return "\(self): cNeurons = \(neurons.count)"
    }

    init(id: KIdentifier, layerRole: ULayer.LayerRole, layerSSInGrid: Int) {
        self.id = id
        self.layerRole = layerRole
        self.layerSSInGrid = layerSSInGrid
    }

    @discardableResult
    func addNeuron(bias: Double, signals: [WeightedSignalProtocol], output: Double)
        -> UNeuron
    {
        let nID = self.id.add(neurons.count, as: .neuron)
        let uN = makeNeuron(id: nID, bias: bias, signals: signals, output: output)

        neurons.append(uN)
        return neurons.last!
    }

    func makeNeuron(id: KIdentifier, bias: Double,
                    signals: [WeightedSignalProtocol], output: Double) -> UNeuron
    {
        preconditionFailure("Subclasses must implement this")
    }

    static func == (_ lhs: ULayer, _ rhs: ULayer) -> Bool { return lhs.id == rhs.id }
}