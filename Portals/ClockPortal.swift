import Foundation
import SpriteKit

class ClockPortal {
    typealias Updater = () -> TimeInterval

    let clockDisplay: SKLabelNode
    var updater: Updater?

    init(_ sprite: SKSpriteNode) {
        guard let clockPortal = sprite.childNode(withName: "clockPortal") as? SKSpriteNode
            else { preconditionFailure() }

        guard let clockDisplay = clockPortal.childNode(withName: "clockDisplay") as? SKLabelNode
            else { preconditionFailure() }

        self.clockDisplay = clockDisplay

        clockDisplay.text = "11:22:33"
        clockDisplay.xScale = 0.75

//        let delayAction = SKAction.wait(forDuration: 1.0)
//
        let updateAction = SKAction.run { [weak self] in
            guard let myself = self else { return }
            guard let clockValue = myself.updater?() else { return }

            let f = DateComponentsFormatter()
            f.allowedUnits = [.hour, .minute, .second]
            f.allowsFractionalUnits = true
            f.unitsStyle = .positional
            f.zeroFormattingBehavior = .pad

            myself.clockDisplay.text = f.string(from: clockValue) ?? "0.0"
        }

//        let updateOncePerSecond = SKAction.sequence([delayAction, updateAction])
//        let updateForever = SKAction.repeatForever(updateOncePerSecond)

//        clockDisplay.run(updateForever)
    }

    func setUpdater(_ updater: @escaping Updater) { self.updater = updater }
}
