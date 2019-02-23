import Foundation
import SpriteKit

class DNet {
    let kNet: KNet

    init(_ kNet: KNet) { self.kNet = kNet }

    func display(via portal: SKSpriteNode) {
        let spacer = DSpacer(portal: portal, cLayers: kNet.hiddenLayers.count)

        let senseLayer = DLayer(
            kNet.senseLayer, layerRole: .senseLayer,
            layerSSInGrid: ArkonCentralDark.isSenseLayer.rawValue
        )

        senseLayer.display(on: portal, spacer: spacer)

        for (ss, kHiddenLayer) in kNet.hiddenLayers.enumerated() {
            let dHiddenLayer = DLayer(kHiddenLayer, layerRole: .hiddenLayer, layerSSInGrid: ss)
            dHiddenLayer.display(on: portal, spacer: spacer)
        }

        let motorLayer = DLayer(
            kNet.motorLayer, layerRole: .motorLayer,
            layerSSInGrid: ArkonCentralDark.isMotorLayer.rawValue
        )

        motorLayer.display(on: portal, spacer: spacer)
    }
}
