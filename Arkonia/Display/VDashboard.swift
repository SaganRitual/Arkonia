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

class VDashboard {
    let cChannels: Int
    var nextAvailableChannel = 0
    weak var scene: SKScene?

    lazy var channels = setupChannels()

    init(cChannels: Int, scene: SKScene) {
        precondition(cChannels == 1 || cChannels == 4)

        self.cChannels = cChannels
        self.scene = scene
    }

    func getChannel() -> SKNode {
        precondition(nextAvailableChannel < channels.count)
        defer { nextAvailableChannel += 1 }
        let c = channels[nextAvailableChannel]
//        (c as! SKSpriteNode).size = WildGuessWindowController.windowDimensions
        return c
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Setup display channels

extension VDashboard {
    func setupChannels() -> [SKNode] {
        return (0..<cChannels).map { channelID_ in
            guard let channelID = Quadrant.init(rawValue: channelID_)
                else { preconditionFailure("Bad channel ID?") }

            return setupChannel(channelID, displaySize: scene!.frame.size)
        }
    }

    func setupChannel(_ channelID: Quadrant, displaySize: CGSize) -> SKSpriteNode {
        let spriteTexture = ArkonCentral.channelBackgroundTexture!
        let quadrantMultipliers: [QuadrantMultiplier] = [(1, 1), (-1, 1), (-1, -1), (1, -1)]
        let quarterOrigin = CGPoint(displaySize / quadrantMultipliers.count)

//        let ts = spriteTexture.size()
        let channel = SKSpriteNode(texture: spriteTexture)
        channel.color = scene!.backgroundColor
        channel.colorBlendFactor = 1.0

        channel.position = cChannels == 1 ? CGPoint(x: 0, y: 0) :
            quarterOrigin * quadrantMultipliers[channelID.rawValue]

        channel.size = displaySize / 2      // Nearly full screen of white, small neurons
//        channel.size = scene!.size / 2  // Small white in middle, small neurons
//        channel.size = scene!.size / 4  // Smaller white, same small neurons
//        channel.size = scene!.size * 2
//        channel.scale(to: scene!.size)

        scene!.addChild(channel)
        return channel
    }
}

