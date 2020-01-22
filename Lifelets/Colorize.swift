import GameplayKit

final class Colorize: Dispatchable {
    internal override func launch() { SceneDispatch.schedule(colorize) }
}

extension Colorize {
    func colorize() {
        guard let (_, dp, st) = scratch?.getKeypoints() else { fatalError() }
        Debug.log("Colorize \(six(st.name))", level: 71)

        Debug.debugColor(st, .blue, .blue)

        let babyBumpIsRunning = st.sprite.action(forKey: "baby-bump") != nil
        let babyBumpShouldBeShowing = st.metabolism.spawnReserves.level < (st.getSpawnCost() * 0.5)

        switch (babyBumpIsRunning, babyBumpShouldBeShowing) {
        case (true, true):  break
        case (false, true): WorkItems.lookPregnant(st.metabolism.oxygenLevel, st.nose)
        default:            WorkItems.lookNotPregnant(st.nose)
        }

        dp.disengage()
    }
}

extension WorkItems {
    private static let d = 0.1
    private static let f: CGFloat = 5

    private static let flatten = SKAction.scaleY(to: Arkonia.noseScaleFactor / f, duration: d)

    private static let lengthen = SKAction.scaleX(to: Arkonia.noseScaleFactor * f, duration: d)

    private static let shorten = SKAction.scaleX(to: Arkonia.noseScaleFactor / f, duration: d)

    private static let unflatten = SKAction.scaleY(to: Arkonia.noseScaleFactor * f, duration: d)

    private static let throb = SKAction.sequence([flatten, unflatten])
    private static let forever = SKAction.repeatForever(throb)

    static func lookPregnant(_ oxygenLevel: CGFloat, _ nose: SKSpriteNode) {
        nose.run(forever, withKey: "baby-bump-nose")
    }
}

extension WorkItems {
    static func lookNotPregnant(_ nose: SKSpriteNode) {
        nose.removeAction(forKey: "baby-bump")
        nose.setScale(Arkonia.noseScaleFactor)
    }
}
