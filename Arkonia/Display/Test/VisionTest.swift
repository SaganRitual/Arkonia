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
import SpriteKit

final class VisionTest {
    var odometer = [1, 1, 1]
    weak var scene: VScene?
    var portal: SKNode
    var splitter: VSplitter

    init(_ scene: VScene) {
        (splitter, portal) = VisionTest.init_(scene)

        self.scene = scene
        self.scene?.setUpdateCallback(self.visualize)
    }

    static func init_(_ scene: VScene) -> (VSplitter, SKNode) {
        let splitter = VSplitter(scene: scene)
        let portal = splitter.getPortal(.one)
        return (splitter, portal)
    }

    func tickOdometer(rollAt: Int) {
        var carry = 1

        odometer = odometer.map {
            let next = carry + $0
            carry = next / (rollAt + 1)

            let maybeZero = next % (rollAt + 1)
            return maybeZero == 0 ? 1 : maybeZero
        }

        if carry != 0 { odometer.append(1) }
    }

    func visualize() {
        let net = VNet(id: KIdentifier("Crashnburn", 0), portal: portal)
        let signalDriver = VSignalDriver(net)

        signalDriver.driveSignal(
            cSenseNeurons: odometer[0], cMotorNeurons: odometer[1],
            hiddenLayerNeuronCounts: odometer[2...]
        )

        net.visualize()
        tickOdometer(rollAt: 5)
    }
}
