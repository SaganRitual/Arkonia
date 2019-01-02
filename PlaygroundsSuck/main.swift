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

let senseSpecs = [
    ConnectionSpec(targets: [GridXY(0, -1)]),
    ConnectionSpec(targets: [GridXY(1, -2)]),
    ConnectionSpec(targets: [GridXY(2, -3)]),
    ConnectionSpec(targets: [GridXY(3, -4)]),
    ConnectionSpec(targets: [GridXY(4, -5)])
]

let theNet = KNet.makeNet(0, cLayers: cLayers)
let sensoryInputs: [KSignalRelay] = (0..<cNeurons as Range<Int>).map {
    let k = KSignalRelay(KIdentifier("Sense", $0))
    k.overrideState(operational: true)
    k.output = 1.0
    return k
}

theNet.driveSignal(sensoryInputs)
print("Releasing output layer relays")

theNet.gridAnchors.forEach { print($0.output) }
theNet.gridAnchors.removeAll()
print("All done")
