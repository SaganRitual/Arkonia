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
//        print("~\(self)")
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

//                print("\(self) check for sense connections intact, \(topHiddenLayer.neurons.compactMap { $0.relay }.count)")
                let senseConnectionsIntact = !topHiddenLayer.neurons.compactMap { $0.relay }.isEmpty
                if !senseConnectionsIntact {
//                    print("\(self) sense connections broken")
                    return false }
            }

            lowerLayer.driveSignal()
            upperLayer = lowerLayer
        }

        if !netIsBuilt {
            motorLayer.reverseConnect(upperLayer)
            upperLayer.decoupleFromGrid()

            if hiddenLayers.isEmpty {
                print("\(self) no guts")
                return false }

            // I'm pretty sure it's counter-productive to have a layer with
            // more neurons than the layer above it. In a trivial case, having
            // a one-neuron layer above a two-neuron layer, the lower neurons
            // are getting exactly the same input value, regardless of anything
            // that has happened in the upper layers. Assuming that I'm right
            // about that point and haven't missed anything important. Kill
            // off any arkons that have such defective nets.

//            var maxAllowedNeurons = Int.max
//            for layer in hiddenLayers {
//                let cLiveNeurons = layer.neurons.compactMap { neuron in neuron.relay }.count
//                if cLiveNeurons > maxAllowedNeurons { return false }
//                maxAllowedNeurons = min(maxAllowedNeurons, cLiveNeurons)
//            }

//            if ArkonCentralDark.selectionControls.cMotorNeurons > maxAllowedNeurons { return false }
        }

        motorLayer.driveSignal()

        if !netIsBuilt { gridAnchors = motorLayer.neurons.map { $0.relay! } }

        return true
    }

    func getNetSignalCost() -> CGFloat {
        return hiddenLayers.reduce(0) { $0 + CGFloat($1.neurons.count) } / 1e7
    }
}
