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

        spacer.setLayerRole(self.layerRole)

        let liveNeurons = layer.neurons.compactMap { $0.relay == nil ? nil : $0 }
        spacer.setHorizontalSpacing(cNeurons: liveNeurons.count)

        for neuron in liveNeurons {
            let dn = DNeuron(neuron)
            dn.display(on: portal, spacer: spacer, inputPositions: inputPositions)

            neuronPositions[dn.neuron.relay!.id] = dn.position
        }
    }
}
