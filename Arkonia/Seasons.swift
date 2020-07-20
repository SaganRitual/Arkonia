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

            // Shift -1...1 sine domain to 0...1
            let weatherIntensityIndex = CGFloat(sin(scaledToSin) + 1) / 2

            // Arkonia uses the proper (celsius) scale, but the temperature
            // always stays in the range of 0.25...1˚C
            let itReallyAmountsToTemperature = max(weatherIntensityIndex, 0.25)

            // dayNightFactor == 1 means midday, 0 is midnight
            let dayNightFactor = self.sun.alpha / Arkonia.maximumBrightnessAlpha

            Debug.log(level: 182) {
                "seasonalFactors:"
                + " julian date \(ageOfYearInDays)"
                + " 0..<1 \(yearCompletion)"
                + " for sin \(scaledToSin)"
                + " temp \(itReallyAmountsToTemperature)"
            }

            onComplete(dayNightFactor, itReallyAmountsToTemperature)
        }
    }

    // Remember: as with pollenators, our update happens during the spritekit scene
    // update, so it's ok for us to hit, for example, ArkoniaScene.currentSceneTime,
    // unprotected, because it's never changed outside the scene update
    func start() {
        let durationToFullLight = Arkonia.realSecondsPerArkoniaDay * Arkonia.darknessAsPercentageOfDay
        let durationToFullDarkness = Arkonia.realSecondsPerArkoniaDay * (1 - Arkonia.darknessAsPercentageOfDay)

        let darken = SKAction.fadeAlpha(
            to: 0,
            duration: durationToFullLight
        )

        let lighten = SKAction.fadeAlpha(
            to: Arkonia.maximumBrightnessAlpha,
            duration: durationToFullDarkness
        )

        let countHalfDay = SKAction.run { self.dayCounter += 0.5 }

        let oneDayOneNight = SKAction.sequence([lighten, countHalfDay, darken, countHalfDay])
        let dayNightCycle = SKAction.repeatForever(oneDayOneNight)

        let realSecondsPerYear = Arkonia.arkoniaDaysPerYear * Arkonia.realSecondsPerArkoniaDay
        let winterDuration = realSecondsPerYear * Arkonia.winterAsPercentageOfYear
        let summerDuration = realSecondsPerYear - winterDuration

        let warm = SKAction.colorize(
            with: .orange, colorBlendFactor: 1,
            duration: winterDuration
        )

        let cool = SKAction.colorize(
            with: .blue, colorBlendFactor: 1,
            duration: summerDuration
        )

        let oneSummerOneWinter = SKAction.sequence([warm, cool])
        let seasonCycle = SKAction.repeatForever(oneSummerOneWinter)

        let bothCycles = SKAction.group([dayNightCycle, seasonCycle])

        sun.run(bothCycles)
    }
}
