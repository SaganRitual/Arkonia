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

class KNeuron: KIdentifiable {
    let activator: AFn.FunctionName
    let bias: Double
    var downConnectors: [Int]
    let id: KIdentifier
    var inputs: [Double]!
    weak var loopIterableSelf: KNeuron?
    weak var relay: KSignalRelay?
    var upConnectors: [UpConnector]
    var weights = [Double]()

    var description: String { return id.description + ", \(weights), \(downConnectors)" }

    init(_ id: KIdentifier) {
        self.id = id
        self.activator = AFn.FunctionName.boundidentity
        self.bias = 0.0
        self.downConnectors = []
        self.inputs = []
        self.upConnectors = []
        loopIterableSelf = self
    }

    init(_ id: KIdentifier, _ fNeuron: FNeuron) {
        self.id = id
        self.activator = fNeuron.activator
        self.bias = fNeuron.bias
        self.downConnectors = fNeuron.downConnectors
        self.upConnectors = fNeuron.upConnectors
        loopIterableSelf = self
    }
}

extension KNeuron {

    func driveSignal(isMotorLayer: Bool) {
        // If we're driving hot, there will likely be holes in the grid,
        // left over from the cold drive. Just skip them.
        guard let relay = relay else { return }

        if isMotorLayer { weights = [1.0] }

        let weighted: [Double] = zip(relay.inputRelays, weights).compactMap {
            (pair: (KSignalRelay, Double)) -> Double? in let (relay, weight) = pair
            return relay.output * weight
        }

//        var logMessage = "\(self) inputs \(relay.inputRelays), weighted \(weighted)"

        relay.output = weighted.reduce(bias, +)
//        logMessage += ", raw output \(relay.output)"
        if let f = AFn.function[self.activator] { relay.output = AFn.clip(f(relay.output)) }
//        logMessage += ", activated \(relay.output)"

        if !upConnectors.isEmpty {
            relay.output = upConnectors[0].amplifier.amplified(relay.output)
        }
//        logMessage += ", amplified \(relay.output)\n"

//        Log.L.write(logMessage)

//        print("\(self) -> \(relay.output)")
    }
}
