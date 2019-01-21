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

class VNet: KIdentifiable {
    var hiddenLayers = [VLayer]()
    let id: KIdentifier
    var motorLayer: VLayer!
    weak var portal: SKNode!
    var senseLayer: VLayer!

    var debugDescription: String {
        return "\(self): cHiddenLayers = \(hiddenLayers.count)"
    }

    init(id: KIdentifier, portal: SKNode) {
        self.id = id
        self.portal = portal
    }

    func addLayer(layerRole: VLayer.LayerRole, layerSSInGrid: Int) -> VLayer {
        if layerRole == .senseLayer {
            let iss = ArkonCentral.isSenseLayer
            let sID = id.add(iss, as: .senseLayer)
            senseLayer = VLayer(
                id: sID, portal: portal, layerRole: layerRole, layerSSInGrid: iss
            )
            return senseLayer
        }

        if layerRole == .motorLayer {
            let ism = ArkonCentral.isMotorLayer
            let mID = id.add(ism, as: .motorLayer)
            motorLayer = VLayer(
                id: mID, portal: portal, layerRole: layerRole, layerSSInGrid: ism
            )
            return motorLayer
        }

        let hID = id.add(layerSSInGrid, as: .hiddenLayer)
        hiddenLayers.append(VLayer(
            id: hID, portal: portal, layerRole: layerRole,
            layerSSInGrid: layerSSInGrid
        ))

        return hiddenLayers.last!
    }

    func visualize() {
        precondition(hiddenLayers.isEmpty == false, "At least one hidden layer is required")

        portal.removeAllChildren()

        let spacer = VSpacer(portal: portal, cLayers: hiddenLayers.count)

        senseLayer.visualize(spacer: spacer)
        hiddenLayers.forEach { $0.visualize(spacer: spacer) }
        motorLayer.visualize(spacer: spacer)
    }
}
