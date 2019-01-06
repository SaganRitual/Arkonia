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

class KNet: KIdentifiable {
    var description: String { return id.description }
    let id: KIdentifier
    var layers: [KLayer]
    var gridAnchors: [KSignalRelay]!

    private init(_ id: KIdentifier, _ layers: [KLayer]) {
        self.id = id; self.layers = layers
    }

    deinit { while !layers.isEmpty { layers.removeLast() } }
}

extension KNet {
    static func makeNet(_ me: Int, tNet: TNet) -> KNet {
        let id = KIdentifier("KNet", me)

        let layers = tNet.layers.enumerated().map { (myID: Int, tLayer: TLayer) -> KLayer in
            let newKLayer = KLayer.makeLayer(id, myID, tLayer)
            return newKLayer
        }

        let kNet = KNet(id, layers)

        return kNet
    }

    func driveSignal(_ sensoryLayer: KLayer, _ motorLayer: KLayer) {
        var iter = layers.makeIterator()
        var upperLayer = iter.next()!

        upperLayer.connect(to: sensoryLayer)
        sensoryLayer.decoupleFromGrid()
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
#endif
