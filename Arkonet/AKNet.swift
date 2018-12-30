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
    var gridAnchors = [K2GridScaffolding]()

    init(_ xLayers: [Translators.Layer]) {
        layers = xLayers.enumerated().map { (arkonID, xLayer) in AKLayer(xLayer, arkonID) }
    }

    func driveSignal(_ sensoryInputs: [Double]) -> [Double?] {
        var iter = layers.makeIterator()

        var upperLayer = iter.next()!
        upperLayer.driveSensoryInputs(sensoryInputs)

        for LL in iter {
            guard let lowerLayer = LL.driveSignal(from: upperLayer)
                else { return [Double?](repeating: nil, count: 50) }

            upperLayer = lowerLayer
        }

        connectionsAreEstablished = true    // Subsequent passes use the existing grid

        gridAnchors = K2SignalGrid.signalGrid.removeScaffolding()
    }

    func setupSignalGrid(_ sensoryInputs: [Double]) -> [Double?] {
        var firstPass = true

        for lowerLayer in layers {
            defer { upperLayer = lowerLayer; firstPass = false }
            var upperLayer = setupSignalGrid(from: upperLayer)

            if firstPass { continue }

            let lowerLayer = LL.setupSignalGrid(from: upperLayer)
            upperLayer = lowerLayer
        }
    }
}
