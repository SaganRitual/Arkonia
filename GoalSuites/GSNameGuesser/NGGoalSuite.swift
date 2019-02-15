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

class NGGoalSuite: GSGoalSuite {
    var huffZoe: UInt64 = 0
    var zero: UInt64 = 0, zNameCount: UInt64 = 0
    let zName: String

    init(_ nameToGuess: String) {
        self.zName = nameToGuess

        ArkonCentralDark.selectionControls =
            NGGoalSuite.setSelectionControls(cMotorNeurons: nameToGuess.count)

        zNameCount = UInt64(nameToGuess.count)
        for vc: UInt64 in zero..<zNameCount { huffZoe <<= 4; huffZoe |= vc }

        let e = 5.7//Double(huffZoe)
        let factory = NGFactory(nameToGuess: nameToGuess)
        let tester = GSTester(expectedOutput: e)

        super.init(factory: factory, tester: tester)
    }

    override class func setSelectionControls(cMotorNeurons: Int) -> KSelectionControls {
        ArkonCentralDark.selectionControls.cSenseNeurons = 5
        ArkonCentralDark.selectionControls.cLayersInStarter = 2
        ArkonCentralDark.selectionControls.cMotorNeurons = cMotorNeurons
        ArkonCentralDark.selectionControls.cGenerations = 10000

        return ArkonCentralDark.selectionControls
    }
}
