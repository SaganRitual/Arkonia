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

// MARK: Colors for connections, depending on the "heat" of the signal, ie, the value

extension DNeuron {
    static let connectionColor = [
        0x5214FF, 0x4214FE, 0x3315FE, 0x2315FD, 0x1617FD, 0x1627FD, 0x1737FC, 0x1747FC, 0x1856FB, 0x1866FB,
        0x1975FB, 0x1985FA, 0x1A94FA, 0x1AA3F9, 0x1BB2F9, 0x1CC0F9, 0x1CCFF8, 0x1DDEF8, 0x1DECF7, 0x1EF7F4,
        0x1EF7E5, 0x1FF6D6, 0x1FF6C7, 0x20F5B9, 0x20F5AA, 0x21F59C, 0x21F48D, 0x22F47F, 0x22F371, 0x23F364,
        0x23F356, 0x24F248, 0x24F23B, 0x25F12D, 0x2AF125, 0x38F126, 0x46F026, 0x54F027, 0x62EF27, 0x70EF28,
        0x7DEF28, 0x8BEE28, 0x98EE29, 0xA5ED29, 0xB2ED2A, 0xBFED2A, 0xCCEC2B, 0xD9EC2B, 0xE5EB2C, 0xEBE42C,
        0xEBD72D, 0xEACA2D, 0xEABD2E, 0xE9B02E, 0xE9A42F, 0xE9972F, 0xE88B2F, 0xE87E30, 0xE77230, 0xE76631,
        0xE75A31, 0xE64E32, 0xE64232, 0xE63632
    ]
}

extension DNeuron {

    func drawConnections(inputPositions: [KIdentifier: CGPoint]) {
        guard let myNeuron = self.neuron else { preconditionFailure() }
        guard let myPosition = self.position else { preconditionFailure() }

        // If my relay has been pruned, there's nothing to draw
        guard let myRelay = myNeuron.relay else { return }

        myRelay.inputRelays.forEach { hisRelay in
            guard let hisPosition = inputPositions[hisRelay.id] else { preconditionFailure() }

            drawLine(from: myPosition, to: hisPosition, heat: hisRelay.output)
        }
    }

    static func makeColor(_ heat: Double) -> NSColor {
        let heatSS = Int(heat * 100)
        let index = connectionColor.index(connectionColor.startIndex, offsetBy: abs(heatSS) % 100)
        let rgb = connectionColor[index]
        let rgbs = String(format: "0x%08X", rgb)
        print("heatSS = \(heatSS), rgb = \(rgbs)")
        let r = Double((rgb >> 16) & 0xFF) / 256
        let g = Double((rgb >>  8) & 0xFF) / 256
        let b = Double(rgb         & 0xFF) / 256

        return NSColor(calibratedRed: CGFloat(r), green: CGFloat(g),
                       blue: CGFloat(b), alpha: CGFloat(1.0))
    }

    @discardableResult
    static func drawLine(from start: CGPoint, to end: CGPoint, color: SKColor) -> SKShapeNode {
        let linePath = CGMutablePath()

        linePath.move(to: start)
        linePath.addLine(to: end)

        let line = SKShapeNode(path: linePath)

        line.strokeColor = color
        line.zPosition = ArkonCentralLight.vLineZPosition

        return line
    }

    private func drawLine(from start: CGPoint, to end: CGPoint, heat: Double) {
        let color = DNeuron.makeColor(heat)
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
