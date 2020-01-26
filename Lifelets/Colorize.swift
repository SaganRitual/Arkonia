import GameplayKit

final class Colorize: Dispatchable {
    internal override func launch() {
        Debug.log(level: 102) { "colorize" }
        SceneDispatch.schedule(colorize)
    }
}

extension Colorize {
    func colorize() {
        guard let (_, dp, st) = scratch?.getKeypoints() else { fatalError() }
        Debug.log(level:71) { "Colorize \(six(st.name))" }

        Debug.debugColor(st, .blue, .blue)

        let babyBumpShouldBeShowing = st.metabolism.spawnReserves.level > (st.getSpawnCost() * 0.5)

        switch babyBumpShouldBeShowing {
        case true:  WorkItems.lookPregnant(st.metabolism.oxygenLevel, st.nose)
        case false: WorkItems.lookNotPregnant(st.nose)
        }

        dp.disengage()
    }
}

extension WorkItems {
    private static let f: CGFloat = Arkonia.zoomFactor

    static func lookPregnant(_ oxygenLevel: CGFloat, _ nose: SKSpriteNode) {
        nose.yScale = Arkonia.noseScaleFactor / f * 2
        nose.xScale = Arkonia.noseScaleFactor * f
    }
}

extension WorkItems {
    static func lookNotPregnant(_ nose: SKSpriteNode) {
        nose.setScale(Arkonia.noseScaleFactor)
    }
}
