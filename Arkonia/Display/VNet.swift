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

typealias QuadrantMultiplier = (x: Double, y: Double)

class VNet: KIdentifiable {
    public enum Quadrant: Int { case one, two, three, four }

    static var sprites = [SKSpriteNode]()

    let id: KIdentifier
    var hiddenLayers = [VLayer]()
    weak var netcam: SKNode?
    var senseLayer: VLayer!
    var motorLayer: VLayer!

    var debugDescription: String {
        return "\(self): cHiddenLayers = \(hiddenLayers.count)"
    }

    init(id: KIdentifier, netcam: SKNode) {
        self.id = id
        self.netcam = netcam
    }

    func addLayer(layerRole: VLayer.LayerRole, layerSSInGrid: Int) -> VLayer {
        if layerRole == .senseLayer {
            let iss = ArkonCentral.isSenseLayer
            let sID = id.add(iss, as: .senseLayer)
            senseLayer = VLayer(id: sID, netcam: netcam!, layerRole: layerRole, layerSSInGrid: iss)
            return senseLayer
        }

        if layerRole == .motorLayer {
            let ism = ArkonCentral.isMotorLayer
            let mID = id.add(ism, as: .motorLayer)
            motorLayer = VLayer(id: mID, netcam: netcam!, layerRole: layerRole, layerSSInGrid: ism)
            return motorLayer
        }

        let hID = id.add(layerSSInGrid, as: .hiddenLayer)
        hiddenLayers.append(VLayer(
            id: hID, netcam: netcam!, layerRole: layerRole, layerSSInGrid: layerSSInGrid
        ))

        return hiddenLayers.last!
    }

    func getNetcam(_ quadrant: Quadrant) -> SKNode { return netcam! }

    func visualize() {
        precondition(hiddenLayers.isEmpty == false, "At least one hidden layer is required")

        netcam!.removeAllChildren()

        let spacer = VSpacer(netcam: netcam!, cLayers: hiddenLayers.count)
        senseLayer.visualize(spacer: spacer)
//        let spazzer = spacer
        hiddenLayers.forEach { $0.visualize(spacer: spacer) }
        motorLayer.visualize(spacer: spacer)
//        motorLayer.visualize(spacer: spazzer)
    }
}
