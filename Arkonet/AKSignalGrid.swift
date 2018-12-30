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

class K2GridScaffolding {
    static var theNeuronNumber = 0
    let neuronNumber: Int
    let uNeuronNumber: Int

    init(_ neuronNumber: Int) {
        self.neuronNumber = neuronNumber
        self.uNeuronNumber = K2GridScaffolding.theNeuronNumber
        print("K2GS(\(neuronNumber),\(uNeuronNumber))")
        K2GridScaffolding.theNeuronNumber += 1
    }

    deinit { print("~K2GS(\(neuronNumber),\(uNeuronNumber))") }

    // Myself. If everyone lets go of this, I destruct.
    weak var anchor: K2GridScaffolding?

    // These are the strong refs to the upper layers; if
    // we remove them from this array, their ref count goes down
    var anchors = [K2GridScaffolding]()
}

struct K2SignalGrid {
    static var signalGrid = K2SignalGrid()

    var grid = [[K2GridScaffolding]]()
    var upperLayer = [K2GridScaffolding]()
    var lowerLayer = [K2GridScaffolding]()

    mutating func attach(_ lowerNeuron: Int, to upperNeuron: Int) {
        let a = upperLayer[upperNeuron].anchor<!>
        lowerLayer[lowerNeuron].anchors.append(a)
    }

    func hasInputs(_ neuronID: Int) -> Bool { return !upperLayer[neuronID].anchors.isEmpty }

    mutating func nextNeuron(_ x: Int) {
        let gss = K2GridScaffolding(x)
        lowerLayer.append(gss)
    }

    mutating func nextLayer() {
        grid.append(upperLayer)
        upperLayer = lowerLayer
        lowerLayer = [K2GridScaffolding]()
    }

    mutating func removeScaffolding() -> [K2GridScaffolding] {
        let anchorLayer = grid.last!
        while !grid.isEmpty {
            var layer = grid.last!
            while !layer.isEmpty { layer.removeLast() }

            grid.removeLast()
        }

        return anchorLayer
    }
}
