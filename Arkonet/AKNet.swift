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

class AKNet {
    var arkonID: Int?
    var layers = [AKLayer]()

    init(_ xLayers: [Translators.Layer]) {
        layers = xLayers.enumerated().map { (arkonID, xLayer) in AKLayer(xLayer, arkonID) }
    }

    func attachRelay(_ sink: (y: Int, x: Int), to source: (y: Int, x: Int)) {
        let sourceNeuron = layers[source.y].neurons[source.x]
        let sinkNeuron = layers[sink.y].neurons[sink.x]

        sinkNeuron.connectToOutput(of: sourceNeuron, weight: 42.42)
    }

    func driveSignal(_ sensoryInputs: [Double]) -> [Double?] {
        var iter = layers.makeIterator()

        var upperLayer = iter.next()!
        upperLayer.driveSensoryInputs(sensoryInputs)

        for LL in iter {
            guard let lowerLayer = LL.driveSignal(from: upperLayer)
                else { return [Double?](repeating: nil, count: 50) }

//            print("removing from layer \(upperLayer.layerID)")
            upperLayer.relays.removeAll()
//            print("removed from layer \(upperLayer.layerID)")
            upperLayer = lowerLayer
        }

        return layers.last!.relays.map { r in if let relay = r { return relay.output } else { return nil } }
    }
}
