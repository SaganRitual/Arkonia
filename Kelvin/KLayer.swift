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
#if !NETCAMS_SMOKE_TEST
import Foundation

class KLayer: KIdentifiable {
    var description: String { return id.description }
    let id: KIdentifier
    let neurons: [KNeuron]
    var signalRelays: [KSignalRelay]

    private init(_ id: KIdentifier, _ neurons: [KNeuron], _ signalRelays: [KSignalRelay]) {
        self.id = id; self.neurons = neurons; self.signalRelays = signalRelays
    }

    deinit { decoupleFromGrid() }
}

extension KLayer {
    static let isMotorLayer = -2
    static let isSenseLayer = -1
}

extension KLayer {
    func connect(to upperLayer: KLayer) {
        neurons.forEach {
            $0.connect(to: upperLayer)
        }
    }

    func decoupleFromGrid() {
        while !signalRelays.isEmpty {
            let r = signalRelays.removeLast()
//            if r.breaker != nil { print("decoupleFromGrid(\(r))") }
//            else { print("decouple dead neuron(\(r))") }

            r.breaker = nil
        }
    }

    func driveSignal() {
        neurons.forEach { $0.driveSignal(isMotorLayer: id.myID == KLayer.isMotorLayer) }
    }

    static func makeLayer(_ family: KIdentifier, _ me: Int, cNeurons: Int) -> KLayer {
        let id = family.add(me, as: .layer)

        let signalRelays = (0..<cNeurons).map { KSignalRelay.makeRelay(id, $0) }

        let neurons: [KNeuron] = signalRelays.enumerated().map { idNumber, relay in
            let newNeuron = KNeuron.makeNeuron(id, idNumber)
            newNeuron.relay = relay
            relay.breaker = relay
            return newNeuron
        }

        return KLayer(id, neurons, signalRelays)
    }

    static func makeLayer(_ family: KIdentifier, _ me: Int, _ tLayer: TLayer) -> KLayer {
        let id = family.add(me, as: .layer)

        let signalRelays = (0..<tLayer.neurons.count).map { KSignalRelay.makeRelay(id, $0) }

        let neurons: [KNeuron] = zip(signalRelays, tLayer.neurons).enumerated().map {
            (arg) in let (idNumber, pair) = arg, relay = pair.0, tNeuron = pair.1

            let newNeuron = KNeuron.makeNeuron(id, idNumber, tNeuron)
            newNeuron.relay = relay
            relay.breaker = relay
            return newNeuron
        }

        return KLayer(id, neurons, signalRelays)
    }

    func reverseConnect(_ lastHiddenLayer: KLayer) {
        lastHiddenLayer.neurons.forEach({ upperNeuron in
            for _ in 0..<upperNeuron.downConnectors.count {
                if upperNeuron.downConnectors.isEmpty { return }

                let connector = upperNeuron.downConnectors.removeLast()
                let outputNeuronSS = connector %% self.neurons.count
                let outputNeuron = self.neurons[outputNeuronSS]

                outputNeuron.relay!.inputRelays.append(upperNeuron.relay!)
//                print("\(outputNeuron.relay!) connects to \(outputNeuron.relay!.inputRelays)")
            }
        })
    }
}

// With profound gratitude to Martin R
// https://stackoverflow.com/users/1187415/martin-r
// https://stackoverflow.com/a/41180619/1610473
//
// A proper modulo operator; Swift's is different from the
// modulo operator of every other language I know.
infix operator %%
func %% (_ a: Int, _ n: Int) -> Int {
    precondition(n > 0, "modulus must be positive")
    let r = a % n
    return r >= 0 ? r : r + n
}
#endif
