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
    weak var scene: VScene?
    var portals: VPortals
    var odometers = [[1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1]]
    var rolls = [3, 9, 2, 6]
    var netSelector = [SKNode : Int]()

    init(_ scene: VScene) {
        self.scene = scene
        self.portals = VPortals(scene: scene)

        (0..<ArkonCentral.cPortals).forEach {
            let p = self.portals.getPortal($0)
            netSelector[p] = $0
            self.scene?.setUpdateCallback(self.visualize, portal: p)
        }
    }

    func tickOdometer(which: Int) {
        var carry = 1

        var iSense = odometers[which].startIndex
        var iMotor = odometers[which].index(after: iSense)
        var iHiddens = odometers[which].index(after: iMotor)

        // This lets me envision the odometers[which] as a real one; the upper two
        // digits are a little funky but the rest of it counts like an odometers[which] does.
        let easierToReasonAbout: ArraySlice<Int> =
            odometers[which][iSense...iSense] +
            odometers[which][iMotor...iMotor] +
            odometers[which][iHiddens...].reversed()

        let t: [Int] = easierToReasonAbout.map {
            let next = carry + $0
            carry = next / (rolls[which] + 1)

            let maybeZero = next % (rolls[which] + 1)
            return maybeZero == 0 ? 1 : maybeZero
        }

        // Reconstruct; damn my failing intellect!
        iSense = t.startIndex
        iMotor = t.index(after: iSense)
        iHiddens = t.index(after: iMotor)

        odometers[which] = Array(t[iSense...iSense] + t[iMotor...iMotor] + t[iHiddens...].reversed())

        if carry != 0 { odometers[which].append(1) }
    }

    func visualize(via portal: SKNode) {
        let net = VNet(id: KIdentifier("Crashnburn", 0), portal: portal)
        let signalDriver = VSignalDriver(net)

        let which = netSelector[portal]!

        signalDriver.driveSignal(
            cSenseNeurons: odometers[which][0], cMotorNeurons: odometers[which][1],
            hiddenLayerNeuronCounts: odometers[which][2...]
        )

        net.visualize()
        tickOdometer(which: which)
    }
}
