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

class KNet: KIdentifiable {
    var description: String { return id.description }
    var gridAnchors: [KSignalRelay]!
    let id: KIdentifier
    var hiddenLayers: [KLayer]
    var motorLayer: KLayer!
    var senseLayer: KLayer!

    private init(_ id: KIdentifier, _ hiddenLayers: [KLayer]) {
        self.id = id; self.hiddenLayers = hiddenLayers
    }

    deinit {
//        print("~\(self)");
        while !hiddenLayers.isEmpty { hiddenLayers.removeLast() }
    }
}

extension KNet {
    static func makeNet(_ me: Int, _ fNet: FNet) -> KNet {
        let id = KIdentifier("KNet", me)

        let layers: [KLayer] = (0..<fNet.layers.count).map {
            let childID = id.add($0, as: .hiddenLayer)
            let newKLayer = KLayer.makeLayer(childID, fNet.layers[$0])
            return newKLayer
        }

        let kNet = KNet(id, layers)

        return kNet
    }

    func driveSignal(_ senseLayer: KLayer, _ motorLayer: KLayer) -> Bool {
        let netIsBuilt = self.senseLayer != nil

        if !netIsBuilt { self.senseLayer = senseLayer; self.motorLayer = motorLayer }

        var iter = hiddenLayers.makeIterator()
        let topHiddenLayer = iter.next()!
        var upperLayer = topHiddenLayer

        if !netIsBuilt {
            upperLayer.connect(to: senseLayer)
            senseLayer.decoupleFromGrid()
        }

        upperLayer.driveSignal()

        for lowerLayer in iter {
            if !netIsBuilt {
                lowerLayer.connect(to: upperLayer)
                upperLayer.decoupleFromGrid()

                let senseConnectionsIntact = !topHiddenLayer.neurons.compactMap { $0.relay }.isEmpty
                if !senseConnectionsIntact { return false }
            }

            lowerLayer.driveSignal()
            upperLayer = lowerLayer
        }

        if !netIsBuilt {
            motorLayer.reverseConnect(upperLayer)
            upperLayer.decoupleFromGrid()

            // No single-neuron layers allowed. No compelling reason, really,
            // except at the moment it bothers me to think about all those
            // cpu cycles driving signals through 25 layers to a single
            // neuron, flattening the signal to uselessness. Think about
            // repairing such nets during the build, by eliminating the
            // problem layers.

            let singleNeuronLayers = !hiddenLayers.filter { layer in
                let relayCount = layer.neurons.compactMap { neuron in neuron.relay }.count
                return relayCount < 2
            }.isEmpty

            if singleNeuronLayers { return false }
        }

        motorLayer.driveSignal()

        if !netIsBuilt { gridAnchors = motorLayer.neurons.map { $0.relay! } }

        return true
    }
}
