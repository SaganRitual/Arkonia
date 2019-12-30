import GameplayKit

final class Colorize: Dispatchable {
    internal override func launch() { colorize() }
}

extension Colorize {
    func colorize() {
        guard let (_, dp, st) = scratch?.getKeypoints() else { fatalError() }
        Log.L.write("Colorize \(six(st.name))", level: 71)

        Debug.debugColor(st, .blue, .blue)

        let babyBumpIsRunning = st.sprite.action(forKey: "baby-bump") != nil
        let babyBumpShouldBeShowing = st.metabolism.spawnReserves.level > st.getSpawnCost()

        switch (babyBumpIsRunning, babyBumpShouldBeShowing) {
        case (true, false): WorkItems.lookPregnant(st.metabolism.oxygenLevel, st.nose)
        case (false, true): WorkItems.lookNotPregnant(st.nose)
        default: break
        }

        dp.disengage()
    }
}

extension WorkItems {
    static let swell = SKAction.scale(by: 1.5, duration: 0.4)

    static func lookPregnant(_ oxygenLevel: CGFloat, _ nose: SKSpriteNode) {
        let shrink = SKAction.scaleX(
            to: Arkonia.spriteScale, y: Arkonia.spriteScale, duration: 0.1
        )

        let discolor = SKAction.colorize(
            with: .purple, colorBlendFactor: 1, duration: 0.25
        )

        let colorBlendFactor = CGFloat(1 - oxygenLevel)

        let recolor = SKAction.colorize(
            with: .green, colorBlendFactor: colorBlendFactor, duration: 0.25
        )

        let throb = SKAction.sequence([WorkItems.swell, shrink])
        let throbColor = SKAction.sequence([discolor, recolor])
        let throbEverything = SKAction.group([throb, throbColor])
        let forever = SKAction.repeatForever(throbEverything)

        nose.run(forever, withKey: "baby-bump-nose")
    }
}

extension WorkItems {
    static func lookNotPregnant(_ sprite: SKSpriteNode) {
        sprite.removeAction(forKey: "baby-bump")

        let shrink = SKAction.scaleX(to: Arkonia.spriteScale, y: Arkonia.spriteScale, duration: 0.5)
        let recolor = SKAction.colorize(with: .green, colorBlendFactor: 1, duration: 0.75)
        let unthrob = SKAction.group([shrink, recolor])

        sprite.run(unthrob)
    }
}
