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
    func addLayer(layerType: KIdentifier.KType, layerSSInGrid: Int) -> KLayer {
        if layerType == .senseLayer {
            let sID = id.add(KLayer.isSenseLayer, as: .senseLayer)
            let cNeurons = ArkonCentral.selectionControls.cSenseNeurons
            senseLayer = KLayer.makeLayer(sID, layerType, cNeurons)
            return senseLayer
        }

        if layerType == .motorLayer {
            let mID = id.add(KLayer.isMotorLayer, as: .motorLayer)
            let cNeurons = ArkonCentral.selectionControls.cMotorNeurons
            motorLayer = KLayer.makeLayer(mID, layerType, cNeurons)
            return motorLayer
        }

        let hID = id.add(layerSSInGrid, as: .hiddenLayer)
        hiddenLayers.append(KLayer.makeLayer(hID, layerType, layerSSInGrid))

        return hiddenLayers.last!
    }

    static func makeNet(_ me: Int, tNet: TNet) -> KNet {
        let id = KIdentifier("KNet", me)

        let layers = tNet.layers.enumerated().map { (myID: Int, tLayer: TLayer) -> KLayer in
            let newKLayer = KLayer.makeLayer(id, myID, tLayer)
            return newKLayer
        }

        let kNet = KNet(id, layers)

        return kNet
    }

    func driveSignal(_ senseLayer: KLayer, _ motorLayer: KLayer) {
        self.senseLayer = senseLayer; self.motorLayer = motorLayer

        var iter = hiddenLayers.makeIterator()
        var upperLayer = iter.next()!

        upperLayer.connect(to: senseLayer)
        senseLayer.decoupleFromGrid()
        upperLayer.driveSignal()

        for lowerLayer in iter {
            lowerLayer.connect(to: upperLayer)
            upperLayer.decoupleFromGrid()

            lowerLayer.driveSignal()
            upperLayer = lowerLayer
        }

        motorLayer.reverseConnect(upperLayer)
        upperLayer.decoupleFromGrid()
        motorLayer.driveSignal()

        gridAnchors = motorLayer.neurons.map { $0.relay! }
    }
}
