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

class RollingAverage {
    let depth = 10
    var values: [Double]

    var ss_ = 0
    var ss: Int {
        get { return ss_ }
        set { ss_ = newValue % depth }
    }

    init() { values = [Double](repeating: 0.0, count: depth) }

    func addSample(_ newValue: Double) -> Double {
        values[ss] = newValue; ss += 1
        return values.reduce(0.0, +) / Double(depth)
    }
}

var ra = RollingAverage()

for _ in 0..<100 {
    let sampleValue = Double.random(in: 0..<100)
    print(sampleValue, terminator: "")

    let average = ra.addSample(sampleValue)
    print(" ", average)
}
