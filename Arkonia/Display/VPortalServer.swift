//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//

import Foundation
import SpriteKit

typealias QuadrantMultiplier = (x: Double, y: Double)

class VPortalServer {
    let cPortals = ArkonCentral.cPortals
    var portals = [Int: SKNode]()
    weak var scene: SKScene?

    init(_ scene: SKScene) {
        precondition(cPortals == 1 || cPortals == 4, "Squares only")
        self.scene = scene
        self.drawPortalSeparators()
    }

    public func getPortal(_ portalNumber: Int) -> SKNode {
        if let portal = portals[portalNumber] { return portal }

        let spriteTexture = ArkonCentral.sceneBackgroundTexture!
        let quadrantMultipliers: [QuadrantMultiplier] = [(1, 1), (-1, 1), (-1, -1), (1, -1)]
        let quarterOrigin = CGPoint(scene!.size / quadrantMultipliers.count)

        let portal = SKSpriteNode(texture: spriteTexture)
        portal.color = scene!.backgroundColor
        portal.colorBlendFactor = 1.0

        portal.position = cPortals == 1 ? CGPoint(x: 0, y: 0) :
            quarterOrigin * quadrantMultipliers[portalNumber]

        // The call to sqrt() is why we only accept squares
        precondition(cPortals > 0)
        let scaleFactor = CGFloat(1.0 / ceil(sqrt(Double(cPortals))))
        portal.size = scene!.size
        portal.setScale(scaleFactor)

        portals[portalNumber] = portal
        scene!.addChild(portal)
        return portal
    }

}

// MARK: For drawing separator lines

extension VPortalServer {

    private func addSeparatorLine(from: CGPoint, to: CGPoint) -> SKShapeNode {
        let line = VSupport.drawLine(from: from, to: to)

        line.strokeColor = .white
        line.glowWidth = 0
        line.zPosition = ArkonCentral.vBorderZPosition
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

            line.yScale = CGFloat(ArkonCentral.vPortalSeparatorsScale)
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
            line.xScale = CGFloat(ArkonCentral.vPortalSeparatorsScale)

            drawHorizontals(lineCount: lineCount)
        }
    }

}
