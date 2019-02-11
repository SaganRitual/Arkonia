import Foundation
import SpriteKit

class DNeuron {
    weak var neuron: KNeuron!
    private weak var portal: SKNode!
    var position: CGPoint?

    init(_ neuron: KNeuron) { self.neuron = neuron }

    func display(on portal: SKNode, spacer: DSpacer, inputPositions: [KIdentifier: CGPoint]) {
        self.portal = portal

        drawNeuron(spacer: spacer)
        drawConnections(inputPositions: inputPositions)
    }
}

extension DNeuron {

    func drawConnections(inputPositions: [KIdentifier: CGPoint]) {
        guard let myNeuron = self.neuron else { preconditionFailure() }
        guard let myPosition = self.position else { preconditionFailure() }

        // If my relay has been pruned, there's nothing to draw
        guard let myRelay = myNeuron.relay else { return }

        myRelay.inputRelays.forEach { hisRelay in
            guard let hisPosition = inputPositions[hisRelay.id] else { preconditionFailure() }

            drawLine(from: myPosition, to: hisPosition)
        }
    }

    @discardableResult
    static func drawLine(from start: CGPoint, to end: CGPoint) -> SKShapeNode {
        let linePath = CGMutablePath()

        linePath.move(to: start)
        linePath.addLine(to: end)

        let line = SKShapeNode(path: linePath)

        line.strokeColor = .green
        line.zPosition = ArkonCentralLight.vLineZPosition

        return line
    }

    private func drawLine(from start: CGPoint, to end: CGPoint) {
        let line = DNeuron.drawLine(from: start, to: end)
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
//        sprite.physicsBody = SKPhysicsBody(circleOfRadius: 15.0)

        sprite.anchorPoint = anchorPoint
        sprite.setScale(ArkonCentralLight.vNeuronScale)
        sprite.position = unscale(spacer.getPosition(for: self))
        sprite.zPosition = ArkonCentralLight.vNeuronZPosition
        self.position = sprite.position
        portal.addChild(sprite)
    }

    private func unscale(_ position: CGPoint) -> CGPoint {
        return position * ArkonCentralLight.vNeuronAntiscale
    }
}
