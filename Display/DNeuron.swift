import Foundation
import SpriteKit

class DNeuron {
    weak var neuron: KNeuron!
    private weak var portal: SKSpriteNode!

    init(_ neuron: KNeuron, spacer: DSpacer, compactGridX: Int, gridY: Int) {
        self.neuron = neuron
        spacer.setPosition(id: neuron.relay!.id, gridX: compactGridX, gridY: gridY)
    }

    func display(on portal: SKSpriteNode, spacer: DSpacer) {
        self.portal = portal

        drawNeuron(spacer: spacer)
        drawConnections(spacer: spacer)
    }
}

extension DNeuron {

    func drawConnections(spacer: DSpacer) {
        guard let myNeuron = self.neuron else { preconditionFailure() }

        // If my relay has been pruned, there's nothing to draw
        guard let myRelay = myNeuron.relay else {
            preconditionFailure("Neuron should have been disqualified in the KNet setup")
        }

        let myPosition = ArkonCentralLight.unscale(spacer.getPosition(for: self.neuron.relay!.id))

        Set<KSignalRelay>(myRelay.inputRelays).forEach { hisRelay in
            let hisPosition = ArkonCentralLight.unscale(spacer.getPosition(for: hisRelay.id))
            drawLine(from: myPosition, to: hisPosition, heat: hisRelay.output)
        }
    }

    @discardableResult
    static func drawLine(from start: CGPoint, to end: CGPoint, color: SKColor) -> SKShapeNode {
        let linePath = CGMutablePath()

        linePath.move(to: start / ArkonCentralLight.vConnectorLineScale)
        linePath.addLine(to: end / ArkonCentralLight.vConnectorLineScale)

        let line = SKShapeNode(path: linePath)

        line.strokeColor = color
        line.setScale(ArkonCentralLight.vConnectorLineScale)
        line.zPosition = ArkonCentralLight.vLineZPosition

        return line
    }

    private func drawLine(from start: CGPoint, to end: CGPoint, heat: Double) {
        let color = NSColor.green
//        let color = DNeuron.makeColor(heat)
        let line = DNeuron.drawLine(from: start, to: end, color: color)
        portal.addChild(line)
    }

    func drawNeuron(spacer: DSpacer) {
        let (texture, anchorPoint): (SKTexture, CGPoint) = {
            switch spacer.layerRole {
            case .hiddenLayer:
                return (ArkonCentralLight.blueNeuronSpriteTexture, CGPoint(x: 0.5, y: 0.5))

            case .senseLayer:
                return (ArkonCentralLight.orangeNeuronSpriteTexture, CGPoint(x: 0.5, y: 1.0))

            case .motorLayer:
                return (ArkonCentralLight.greenNeuronSpriteTexture, CGPoint(x: 0.5, y: 0.0))
            }
        }()

        let sprite = SKSpriteNode(texture: texture)

        sprite.anchorPoint = anchorPoint
        sprite.setScale(ArkonCentralLight.vNeuronScale)
        sprite.position = ArkonCentralLight.unscale(spacer.getPosition(for: self.neuron.relay!.id))
        sprite.zPosition = ArkonCentralLight.vNeuronZPosition
        portal.addChild(sprite)
    }
}
