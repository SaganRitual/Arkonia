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
    var senseLayer: VLayer!

    var debugDescription: String {
        return "\(self): cHiddenLayers = \(hiddenLayers.count)"
    }

    init(id: KIdentifier) { self.id = id }

    func addLayer(layerRole: VLayer.LayerRole, layerSSInGrid: Int) -> VLayer {
        if layerRole == .senseLayer {
            let iss = ArkonCentralDark.isSenseLayer
            let sID = id.add(iss, as: .senseLayer)
            senseLayer = VLayer(id: sID, layerRole: layerRole, layerSSInGrid: iss)
            return senseLayer
        }

        if layerRole == .motorLayer {
            let ism = ArkonCentralDark.isMotorLayer
            let mID = id.add(ism, as: .motorLayer)
            motorLayer = VLayer(id: mID, layerRole: layerRole, layerSSInGrid: ism)
            return motorLayer
        }

        let hID = id.add(layerSSInGrid, as: .hiddenLayer)
        hiddenLayers.append(VLayer(id: hID, layerRole: layerRole, layerSSInGrid: layerSSInGrid))

        return hiddenLayers.last!
    }

    func display(on portal: SKNode) {
        precondition(hiddenLayers.isEmpty == false, "At least one hidden layer is required")

        portal.removeAllChildren()

        let spacer = VSpacer(portal: portal, cLayers: hiddenLayers.count)

        senseLayer.display(on: portal, spacer: spacer)
        hiddenLayers.forEach { $0.display(on: portal, spacer: spacer) }
        motorLayer.display(on: portal, spacer: spacer)
    }
}
