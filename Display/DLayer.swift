import Foundation
import SpriteKit

class DLayer {
    enum LayerRole { case senseLayer, hiddenLayer, motorLayer }

    let layer: KLayer
    let layerRole: LayerRole
    var neuronPositions = [KIdentifier: CGPoint]()

    init(_ layer: KLayer, layerRole: LayerRole) { self.layer = layer; self.layerRole = layerRole }

    func display(on portal: SKNode, spacer spacer_: DSpacer, inputPositions: [KIdentifier: CGPoint]) {
        var spacer = spacer_
        spacer.setHorizontalSpacing(cNeurons: layer.neurons.count)
        spacer.setLayerRole(self.layerRole)

        for neuron in layer.neurons {
            guard let relay = neuron.relay else { continue }

            let dn = DNeuron(neuron)
            dn.display(on: portal, spacer: spacer, inputPositions: inputPositions)

            neuronPositions[relay.id] = dn.position
        }
    }
}
