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

    func getSeasonalFactors(_ onComplete: @escaping (CGFloat, CGFloat) -> Void) {
        SceneDispatch.shared.schedule {
            let ageOfYearInDays = self.dayCounter.truncatingRemainder(dividingBy: Arkonia.arkoniaDaysPerYear)
            let yearCompletion: TimeInterval = ageOfYearInDays / Arkonia.arkoniaDaysPerYear
            let scaledToSin = yearCompletion * TimeInterval.tau
            let weatherIntensityIndex = (sin(scaledToSin) + 1) / 2

            // dayNightFactor == 1 means midday, 0 is midnight
            let dayNightFactor = self.sun.alpha / Arkonia.maximumBrightnessAlpha

            Debug.log(level: 182) {
                "seasonalFactors:"
                + " julian date \(ageOfYearInDays)"
                + " 0..<1 \(yearCompletion)"
                + " for sin \(scaledToSin)"
                + " weather \(weatherIntensityIndex)"
            }

            onComplete(dayNightFactor, CGFloat(weatherIntensityIndex))
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

        let countHalfDay = SKAction.run { self.dayCounter += 0.5 }

        let oneDayOneNight = SKAction.sequence([lighten, countHalfDay, darken, countHalfDay])
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
