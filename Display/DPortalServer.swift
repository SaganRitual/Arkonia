import Foundation
import SpriteKit

typealias QuadrantMultiplier = (x: Double, y: Double)

class DPortalServer {
    let cPortals = ArkonCentralLight.cPortals
    var portals = [Int: SKNode]()
    weak var scene: SKScene?

    init(_ scene: SKScene) {
        precondition(cPortals == 1 || cPortals == 4, "Squares only")
        self.scene = scene
        self.drawPortalSeparators()
    }

    public func getPortal(_ portalNumber: Int) -> SKNode {
        if let portal = portals[portalNumber] { return portal }

        let spriteTexture = ArkonCentralLight.sceneBackgroundTexture!
        let quadrantMultipliers: [QuadrantMultiplier] = [(1, 1), (-1, 1), (-1, -1), (1, -1)]
        let quarterOrigin = CGPoint(scene!.size / quadrantMultipliers.count)

        let portal = SKSpriteNode(texture: spriteTexture)
        portal.color = scene!.backgroundColor
        portal.colorBlendFactor = 1.0

        portal.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        portal.position = cPortals == 1 ? CGPoint(x: 0, y: 0) :
            quarterOrigin * quadrantMultipliers[portalNumber]

        // The call to sqrt() is why we only accept squares
        precondition(cPortals > 0)
        portal.size = KAppController.shared.scene?.size ?? CGSize(width: 42, height: 42)

        // FIXME: Yuck! Different treatment for different portals?
        if portalNumber == 0 {
            let scaleFactor = CGFloat(1.0 / ceil(sqrt(Double(cPortals))))
            portal.setScale(scaleFactor)
        }

        portals[portalNumber] = portal
        scene!.addChild(portal)

        return portal
    }

}

// MARK: For drawing separator lines

extension DPortalServer {

    private func addSeparatorLine(from: CGPoint, to: CGPoint) -> SKShapeNode {
        let line = DNeuron.drawLine(from: from, to: to, color: .white)

        line.glowWidth = 0
        line.zPosition = ArkonCentralLight.vBorderZPosition
        self.scene!.addChild(line)

        return line
    }

    private func drawHorizontals(lineCount: Int) {
        let size = self.scene!.size

        let vSpacing = size.height / CGFloat(lineCount + 1)
        let left = -size.width / 2
        let right = size.width / 2

        for yy in 0..<lineCount {
            let y = CGFloat(yy + 1) * vSpacing - vSpacing

            let line = addSeparatorLine(
                from: CGPoint(x: left, y: y), to: CGPoint(x: right, y: y)
            )

            line.yScale = CGFloat(ArkonCentralLight.vPortalSeparatorsScale)
        }
    }

    private func drawPortalSeparators() {
        let scaleFactor = CGFloat(1.0 / ceil(sqrt(Double(cPortals))))

        let lineCount = Int(1.0 / scaleFactor) - 1
        if lineCount == 0 { return }

        let size = self.scene!.size

        let top = size.height / 2
        let bottom = -size.height / 2
        let hSpacing = size.width / CGFloat(lineCount + 1)

        for xx in 0..<lineCount {
            let x = CGFloat(xx + 1) * hSpacing - hSpacing

            let line = addSeparatorLine(from: CGPoint(x: x, y: top), to: CGPoint(x: x, y: bottom))
            line.xScale = CGFloat(ArkonCentralLight.vPortalSeparatorsScale)

            drawHorizontals(lineCount: lineCount)
        }
    }

}
