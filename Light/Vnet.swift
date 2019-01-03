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

class Vnet {
    public enum Quadrant: Int {
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

    let gameScene: GameScene
    var netcams = [SKShapeNode]()
    let scale: CGFloat

    init(gameScene: GameScene) {
        self.gameScene = gameScene

        let numberOfquadrantMultipliers = 4
        let quarterOrigin = CGPoint(gameScene.size / numberOfquadrantMultipliers)

        let quadrantMultipliers: [QuadrantMultiplier] = [(1, 1), (-1, 1), (-1, -1), (1, -1)]

        scale = CGFloat(2.0 * (1.0 / CGFloat(numberOfquadrantMultipliers)))

        for qm in quadrantMultipliers {
            let netcam = SKShapeNode(rectOf: gameScene.size)
            netcam.position = quarterOrigin * qm
            netcam.fillColor = gameScene.backgroundColor
            netcams.append(netcam)
            netcam.setScale(scale)
            gameScene.addChild(netcam)
        }
    }

    func getNetcam(_ quadrant: Quadrant) -> SKShapeNode {
        let ss = quadrant.rawValue
        return netcams[ss]
    }
}
