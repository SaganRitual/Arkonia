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

class VNet: UNet {
    func display(on portal: SKNode) {
        precondition(hiddenLayers.isEmpty == false, "At least one hidden layer is required")

        portal.removeAllChildren()

        let spacer = VSpacer(portal: portal, cLayers: hiddenLayers.count)

        guard let senseLayer = self.senseLayer as? VLayer else { preconditionFailure() }
        guard let motorLayer = self.motorLayer as? VLayer else { preconditionFailure() }

        senseLayer.display(on: portal, spacer: spacer)

        hiddenLayers.map { $0 }.forEach {
            nok($0 as? VLayer).display(on: portal, spacer: spacer)
        }

        motorLayer.display(on: portal, spacer: spacer)
    }

    override func makeLayer(id: KIdentifier, layerRole: ULayer.LayerRole, layerSSInGrid: Int)
        -> ULayer
    {
        return VLayer(id: id, layerRole: layerRole, layerSSInGrid: layerSSInGrid)
    }
}
