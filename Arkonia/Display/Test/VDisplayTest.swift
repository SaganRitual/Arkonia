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

final class VDisplayTest {

    var odometers = [[1, 1, 1], [1, 1, 1], [1, 1, 1], [1, 1, 1]]
    var portalNumbers = [SKNode : Int]()
    var rolls = [3, 9, 2, 6]
    var tNet: TNet?

    private func buildTNet(_ portal: SKNode) -> TNet {
        let net = TNet()
        let p = portalNumbers[portal] !! { preconditionFailure() }
        let od = odometers[p]
        let startOfHiddenLayers = od.index(0, offsetBy: 2)

        for cNeurons in od[startOfHiddenLayers...] {
            let layer = net.beginNewLayer()

            for _ in 0..<cNeurons {
                _ = layer.beginNewNeuron()
                layer.finalizeNeuron()
            }

            net.finalizeLayer()
        }

        net.cSenseNeurons = od[od.index(0, offsetBy: 0)]
        net.cMotorNeurons = od[od.index(0, offsetBy: 1)]

        return net
    }

    func displayNet(_ portal: SKNode) {
        let display = ArkonCentralLight.display !! { preconditionFailure() }

        tNet = buildTNet(portal)
        display.newTNetAvailable(tNet!, portal: portal)
    }

    func start() {
        let d = ArkonCentralLight.display !! { preconditionFailure() }
        (0..<ArkonCentralLight.cPortals).forEach {
            let portal = d.portalServer.getPortal($0)
            portalNumbers[portal] = $0
            d.registerForSceneTick(update(_:), portal: portal)
        }
    }

    private func tickOdometer(_ portal: SKNode) {
        let portalNumber = portalNumbers[portal] !! { preconditionFailure() }
        var carry = 1

        var iSense = odometers[portalNumber].startIndex
        var iMotor = odometers[portalNumber].index(after: iSense)
        var iHiddens = odometers[portalNumber].index(after: iMotor)

        // This lets me envision the odometers[portalNumber] as a real one; the upper two
        // digits are a little funky but the rest of it counts like a real odometer does.
        let easierToReasonAbout: ArraySlice<Int> =
            odometers[portalNumber][iSense...iSense] +
            odometers[portalNumber][iMotor...iMotor] +
            odometers[portalNumber][iHiddens...].reversed()

        let t: [Int] = easierToReasonAbout.map {
            let next = carry + $0
            carry = next / (rolls[portalNumber] + 1)

            let maybeZero = next % (rolls[portalNumber] + 1)
            return maybeZero == 0 ? 1 : maybeZero
        }

        // Reconstruct; damn my failing intellect!
        iSense = t.startIndex
        iMotor = t.index(after: iSense)
        iHiddens = t.index(after: iMotor)

        odometers[portalNumber] =
            Array(t[iSense...iSense] + t[iMotor...iMotor] + t[iHiddens...].reversed())

        if carry != 0 { odometers[portalNumber].append(1) }
    }

    func update(_ portal: SKNode) {
        displayNet(portal)
        tickOdometer(portal)
    }
}
