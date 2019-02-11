import Foundation
import SpriteKit

class DNet {
    let kNet: KNet

    init(_ kNet: KNet) { self.kNet = kNet }

    func display(via portal: SKNode) {
        let spacer = DSpacer(portal: portal, cLayers: kNet.hiddenLayers.count)

        let senseLayer = DLayer(kNet.senseLayer, layerRole: .senseLayer)
        senseLayer.display(on: portal, spacer: spacer, inputPositions: [:])

        var inputsToNextLayer = senseLayer.neuronPositions

        kNet.hiddenLayers.forEach {
            let hiddenLayer = DLayer($0, layerRole: .hiddenLayer)
            hiddenLayer.display(on: portal, spacer: spacer, inputPositions: inputsToNextLayer)
            inputsToNextLayer = hiddenLayer.neuronPositions
        }

        let motorLayer = DLayer(kNet.motorLayer, layerRole: .motorLayer)
        motorLayer.display(on: portal, spacer: spacer, inputPositions: inputsToNextLayer)
    }
}
