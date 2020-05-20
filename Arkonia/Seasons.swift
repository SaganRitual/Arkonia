import SpriteKit

extension Double {
    static let tau = 2 * Double.pi
}

class Seasons {
    static var shared: Seasons!

    var dayCounter: TimeInterval = 0
    let sun: SKSpriteNode

    init() {
        let atlas = SKTextureAtlas(named: "Backgrounds")
        let texture = atlas.textureNamed("sun")

        self.sun = SKSpriteNode(texture: texture)

        sun.alpha = 0       // Start the world at midnight
        sun.color = .blue
        sun.colorBlendFactor = 1
        sun.size = ArkoniaScene.arkonsPortal!.size

        ArkoniaScene.arkonsPortal!.addChild(sun)

        start()
    }

    func getSeasonalFactors(_ onComplete: @escaping (CGFloat) -> Void) {
        SceneDispatch.shared.schedule {
            let ageOfYearInDays = self.dayCounter.truncatingRemainder(dividingBy: Arkonia.arkoniaDaysPerYear)
            let yearCompletion: TimeInterval = ageOfYearInDays / Arkonia.arkoniaDaysPerYear
            let scaledToSin = yearCompletion * TimeInterval.tau
            let weatherIntensityIndex = (sin(scaledToSin) + 1) / 2

            // dayNightFactor == 1 means midday, 0 is midnight
            let dayNightFactor = self.sun.alpha / Arkonia.maximumBrightnessAlpha

            let seasonalFactors = dayNightFactor * CGFloat(weatherIntensityIndex)

            onComplete(seasonalFactors)
        }
    }

    // Remember: as with pollenators, our update happens during the spritekit scene
    // update, so it's ok for us to hit, for example, ArkoniaScene.currentSceneTime,
    // unprotected, because it's never changed outside the scene update
    func start() {
        let darken = SKAction.fadeAlpha(
            to: 0,
            duration: Arkonia.realSecondsPerArkoniaDay / 2
        )

        let lighten = SKAction.fadeAlpha(
            to: Arkonia.maximumBrightnessAlpha,
            duration: Arkonia.realSecondsPerArkoniaDay / 2
        )

        let countDays = SKAction.run { self.dayCounter += 1 }

        let oneDayOneNight = SKAction.sequence([lighten, darken, countDays])
        let dayNightCycle = SKAction.repeatForever(oneDayOneNight)

        let realSecondsPerArkoniaSeason = TimeInterval(Arkonia.arkoniaDaysPerSeason) * Arkonia.realSecondsPerArkoniaDay

        let warm = SKAction.colorize(
            with: .yellow, colorBlendFactor: 1,
            duration: realSecondsPerArkoniaSeason / 2
        )

        let cool = SKAction.colorize(
            with: .blue, colorBlendFactor: 1,
            duration: realSecondsPerArkoniaSeason / 2
        )

        let oneSummerOneWinter = SKAction.sequence([warm, cool])
        let seasonCycle = SKAction.repeatForever(oneSummerOneWinter)

        let bothCycles = SKAction.group([dayNightCycle, seasonCycle])

        sun.run(bothCycles)
    }
}
