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

// MARK: Stuff that I factored out so the unit tests don't link to half the world

extension KNeuron {
    func connect(to upperLayer: KLayer) {
        let connector = KConnector(self)
        let targetNeurons = connector.selectOutputs(from: upperLayer)

        hardBind(relay).connect(to: targetNeurons, in: upperLayer)
    }

    static func makeNeuron(_ newNeuronID: KIdentifier, _ fNeuron: FNeuron) -> KNeuron {
        return KNeuron(newNeuronID, fNeuron)
    }

    // For sensory layer and motor layer.
    static func makeNeuron(_ family: KIdentifier, _ me: Int) -> KNeuron {
        let id = family.add(me, as: .neuron)
        return KNeuron(id)
    }
}

extension KSignalRelay {
    static func makeRelay(_ family: KIdentifier, _ me: Int) -> KSignalRelay {
        let id = family.add(me, as: .signalRelay)
        return KSignalRelay(id)
    }

    func connect(to targetNeurons: [Int], in upperLayer: KLayer) {
        inputRelays = targetNeurons.map {
            upperLayer.neurons[$0].relay!
        }
    }

    func overrideState(operational: Bool) { overriddenState = operational }
}
