import Foundation
import SpriteKit

class DLayer {
    enum LayerRole { case senseLayer, hiddenLayer, motorLayer }

    let layer: KLayer
    let layerRole: LayerRole
    let layerSSInGrid: Int

    init(_ layer: KLayer, layerRole: LayerRole, layerSSInGrid: Int) {
        self.layer = layer; self.layerRole = layerRole; self.layerSSInGrid = layerSSInGrid
    }

    func display(on portal: SKSpriteNode, spacer: DSpacer) {
        spacer.setLayerRole(self.layerRole)

        let liveNeurons = layer.neurons.compactMap { $0.relay == nil ? nil : $0 }
        spacer.setHorizontalSpacing(cNeurons: liveNeurons.count)

        for (ss, neuron) in liveNeurons.enumerated() {
            let dn = DNeuron(neuron, spacer: spacer, compactGridX: ss, gridY: self.layerSSInGrid)
            dn.display(on: portal, spacer: spacer)
        }
    }
}
