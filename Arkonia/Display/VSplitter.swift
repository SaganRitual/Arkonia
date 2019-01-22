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

public enum Quadrant: Int, CaseIterable {
    case one, two, three, four

    func nextQuadrant(_ q: Quadrant) -> Quadrant {
        switch q {
        case .one: return .two
        case .two: return .three
        case .three: return .four
        case .four: return .one
        }
    }
}

class VSplitter {
    let cPortals = ArkonCentral.cPortals
    var portals = [Quadrant: SKNode]()
    var nextAvailablePortal = 0
    weak var scene: SKScene?

    init(scene: SKScene) {
        precondition(cPortals == 1 || cPortals == 4, "Squares only")

        self.scene = scene
    }

    public func getPortal(_ portalID: Quadrant) -> SKSpriteNode {
        precondition(portals[portalID] == nil, "Attempt to reuse portal \(portalID)")

        let spriteTexture = ArkonCentral.sceneBackgroundTexture!
        let quadrantMultipliers: [QuadrantMultiplier] = [(1, 1), (-1, 1), (-1, -1), (1, -1)]
        let quarterOrigin = CGPoint(scene!.size / quadrantMultipliers.count)

        let portal = SKSpriteNode(texture: spriteTexture)
        portal.color = scene!.backgroundColor
        portal.colorBlendFactor = 1.0

        portal.position = cPortals == 1 ? CGPoint(x: 0, y: 0) :
            quarterOrigin * quadrantMultipliers[portalID.rawValue]

        // The call to sqrt() is why we only accept squares
        precondition(cPortals > 0)
        let scaleFactor = CGFloat(1.0 / ceil(sqrt(Double(cPortals))))
        portal.size = scene!.size
        portal.setScale(scaleFactor)

        portals[portalID] = portal
        scene!.addChild(portal)
        return portal
    }
}

