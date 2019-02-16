import Foundation
import SpriteKit

class DNeuron {
    weak var neuron: KNeuron!
    private weak var portal: SKNode!

    init(_ neuron: KNeuron, spacer: DSpacer, compactGridX: Int, gridY: Int) {
        self.neuron = neuron
        spacer.setPosition(id: neuron.relay!.id, gridX: compactGridX, gridY: gridY)
    }

    func display(on portal: SKNode, spacer: DSpacer) {
        self.portal = portal

        drawNeuron(spacer: spacer)
        drawConnections(spacer: spacer)
    }
}

// MARK: Colors for connections, depending on the "heat" of the signal, ie, the value

extension DNeuron {
    static let connectionColors = [
        0x8257FF, 0x7656FE, 0x6A55FD, 0x5E54FC, 0x5354FB, 0x525FFA, 0x5169F9, 0x5174F8,
        0x507EF7, 0x4F88F6, 0x4E93F5, 0x4D9DF4, 0x4DA7F3, 0x4CB2F2, 0x4BBCF1, 0x4AC6F0,
        0x49D0EF, 0x49DBEE, 0x48E5ED, 0x47ECE9, 0x46EBDD, 0x45EAD1, 0x45E9C5, 0x44E8B9,
        0x43E7AD, 0x42E6A1, 0x42E595, 0x41E489, 0x40E37E, 0x3FE272, 0x3FE166, 0x3EE05A,
        0x3DE04F, 0x3CDF43, 0x40DE3C, 0x4ADD3B, 0x54DC3A, 0x5FDB3A, 0x69DA39, 0x73D938,
        0x7DD837, 0x87D737, 0x91D636, 0x9AD535, 0xA4D435, 0xAED334, 0xB8D233, 0xC2D133,
        0xCBD032, 0xCFC931, 0xCEBE31, 0xCDB230, 0xCCA72F, 0xCB9B2F, 0xCA902E, 0xC9842D,
        0xC8792D, 0xC76E2C, 0xC6632C, 0xC5582B, 0xC44C2A, 0xC3412A, 0xC23629, 0xC22C29
    ].reversed()
}

extension DNeuron {

    static func constrain<T: Numeric & Comparable>(_ a: T, lo: T, hi: T) -> T {
        let capped = min(a, hi)
        return max(capped, lo)
    }

    func drawConnections(spacer: DSpacer) {
        guard let myNeuron = self.neuron else { preconditionFailure() }

        // If my relay has been pruned, there's nothing to draw
        guard let myRelay = myNeuron.relay else { return }

        let myPosition = DNeuron.unscale(spacer.getPosition(for: self.neuron.relay!.id))

        myRelay.inputRelays.forEach { hisRelay in
            let hisPosition = DNeuron.unscale(spacer.getPosition(for: hisRelay.id))
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
//        let color = DNeuron.makeColor(heat)
        let color = ArkonCentralLight.makeColor(hexRGB: 0x47db47)
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
        sprite.position = DNeuron.unscale(spacer.getPosition(for: self.neuron.relay!.id))
        sprite.zPosition = ArkonCentralLight.vNeuronZPosition
        portal.addChild(sprite)
    }

    static func makeColor(_ heat: Double) -> NSColor {
        // Map the -1.0..<1.0 range to my 0-99 range of heat colors
        let scale = connectionColors.count

        // Constrain to -1.0...1.0
        let constrained = constrain(heat, lo: -1.0, hi: 1.0)
        // Shift to 0.0...2.0
        let shifted = constrained + 1.0
        // Map value in range 0.0...2.0 to range 0.0...(colors.count)
        let scaled = Int(shifted * Double(scale) / 2.0)
        // Don't go off the end
        let colorSS = min(scaled, scale - 1)

        let index = connectionColors.index(connectionColors.startIndex, offsetBy: colorSS)

        return ArkonCentralLight.makeColor(hexRGB: connectionColors[index])
    }

    static private func unscale(_ position: CGPoint) -> CGPoint {
        return position * ArkonCentralLight.vNeuronAntiscale
    }
}
