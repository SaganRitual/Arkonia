import GameplayKit

final class Colorize: Dispatchable {
    internal override func launch() { colorize() }
}

extension Colorize {
    func colorize() {
        guard let (_, dp, st) = scratch?.getKeypoints() else { fatalError() }
        Debug.log("Colorize \(six(st.name))", level: 71)

        Debug.debugColor(st, .blue, .blue)

        let babyBumpIsRunning = st.sprite.action(forKey: "baby-bump") != nil
        let babyBumpShouldBeShowing = st.metabolism.spawnReserves.level < (st.getSpawnCost() / 2)

        switch (babyBumpIsRunning, babyBumpShouldBeShowing) {
        case (true, true):  break
        case (false, true): WorkItems.lookPregnant(st.metabolism.oxygenLevel, st.nose)
        default:            WorkItems.lookNotPregnant(st.nose)
        }

        dp.disengage()
    }
}

extension WorkItems {
    static func lookPregnant(_ oxygenLevel: CGFloat, _ nose: SKSpriteNode) {
        let d = 0.25

        let flatten = SKAction.scaleY(to: Arkonia.noseScaleFactor / 5, duration: d)

        let lengthen = SKAction.scaleX(to: Arkonia.noseScaleFactor * 5, duration: d)

        let shorten = SKAction.scaleX(to: Arkonia.noseScaleFactor / 5, duration: d)

        let unflatten = SKAction.scaleY(to: Arkonia.noseScaleFactor * 5, duration: d)

        let throb = SKAction.sequence([flatten, lengthen, shorten, unflatten])
        let forever = SKAction.repeatForever(throb)

        nose.run(forever, withKey: "baby-bump-nose")
    }
}

extension WorkItems {
    static func lookNotPregnant(_ nose: SKSpriteNode) {
        nose.removeAction(forKey: "baby-bump")
        nose.setScale(Arkonia.noseScaleFactor)
    }
}
