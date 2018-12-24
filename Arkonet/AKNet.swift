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
    var connectionsAreEstablished = false
    var layers = [AKLayer]()

    init(_ xLayers: [Translators.Layer]) {
        layers = xLayers.enumerated().map { (arkonID, xLayer) in AKLayer(xLayer, arkonID) }
    }

//    deinit { print("~AKNet", nilstr(arkonID)) }

    func driveSignal(_ sensoryInputs: [Double]) -> [Double?] {
        var iter = layers.makeIterator()

        var upperLayer = iter.next()!
        upperLayer.driveSensoryInputs(sensoryInputs)

        for LL in iter {
            let establishConnections = !connectionsAreEstablished
            guard let lowerLayer = LL.driveSignal(from: upperLayer, establishConnections)
                else { return [Double?](repeating: nil, count: 50) }

            // It would be ok to call remove() even if it were empty. I'm leaving
            // this here as a reminder to myself that we're re-using the
            // same layers from the previous stim pass, not creating new
            // ones every time--concerning which, I have no idea how it
            // ever even seemed to work.
            if !upperLayer.relays.isEmpty { upperLayer.relays.removeAll() }

            upperLayer = lowerLayer
        }

        connectionsAreEstablished = true    // Subsequent passes use the existing grid

        return layers.last!.relays.map { r in if let relay = r { return relay.output } else { return nil } }
    }
}
