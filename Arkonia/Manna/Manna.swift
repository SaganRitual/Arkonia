import SpriteKit

class Manna {
    let absoluteGridIndex: Int
    var cHarvests = 0
    fileprivate var timeRequiredForFullBloom = Arkonia.mannaFullGrowthDurationSeconds
    fileprivate var mostRecentBloomTime: Date
    let sprite: Manna.Sprite

    var isPhotosynthesizing: Bool { self.sprite.isPhotosynthesizing }

    init(_ absoluteGridIndex: Int) {
        self.absoluteGridIndex = absoluteGridIndex
        self.sprite = Manna.Sprite()
        self.sprite.reset()

        // Set our date to the past so we'll treat the first bloom as completed already
        self.mostRecentBloomTime = Date() - Arkonia.mannaFullGrowthDurationSeconds
    }
}

extension Manna {
    class Sprite {
        let sprite: SKSpriteNode

        init() {
            sprite = SpriteFactory.shared.mannaPool.makeSprite()

            SpriteFactory.shared.mannaPool.attachSprite(sprite)
        }
    }
}

extension Manna {
    func harvest(_ onComplete: @escaping (EnergyBudget.MannaContent?) -> Void) {
        cHarvests += 1

        let maturityLevel = sprite.getMaturityLevel()

        // Don't give up any nutrition at all until I've bloomed enough
        if maturityLevel < 1e-2 {
            mainDispatch { onComplete(nil) }
            return
        }

        MannaStats.stats.updateMannaStat(.photosynthesizing, by: -1)

        Clock.dispatchQueue.async {
            let temperature = SeasonalFactors(Clock.shared.worldClock).temperature
            let scaleZeroToOne = (temperature + 1) / 2  // Convert -1..<1 to 0..<1
            let mannaContent = EnergyBudget.MannaContent(maturityLevel, scaleZeroToOne)

            Debug.log(level: 220) {
                "harvest at \(self.absoluteGridIndex):"
                + " maturity \(maturityLevel) * temperature \(temperature)"
                + " = \(maturityLevel * temperature)"
                + " -> ham \(mannaContent.selectStore(.energy)!)"
            }

            MannaCannon.shared.updateFoodValue(newSample: Double(mannaContent.selectStore(.energy)!))
            SceneDispatch.shared.schedule("rebloom", self.rebloom)
            mainDispatch { onComplete(mannaContent) }
        }
    }

    func rebloom() {
        hardAssert(Display.displayCycle == .updateStarted) { "hardAssert at \(#file):\(#line)" }

        sprite.reset()

        // Check for pollenators above me; if none, go back to sleep for a while
        guard let pollenator = MannaCannon.shared.pollenators.first(
            where: { $0.node.contains(sprite.sprite.position) }
        ) else { MannaCannon.shared.blast(self); return }

        // If I'm being harvested before I've reached full maturity, it will
        // take proportionally longer for me to reach it this time. The delay is
        // cumulative: say the normal bloom time is 10s, and I mature only up to
        // 6.3s, when an arkon grazes me. It will take me a total of
        // (normal bloom time + (10 - 6.3s)) * 10s/5s =
        // (normal bloom time + 3.7) * 2 seconds to reach full maturity
        let now = Date()
        let growthDuration = mostRecentBloomTime.distance(to: now)
        let maturity = constrain(growthDuration / timeRequiredForFullBloom, lo: 0.5, hi: 1.0)
        let catchup = timeRequiredForFullBloom * (1 - maturity)

        timeRequiredForFullBloom = catchup + Arkonia.mannaFullGrowthDurationSeconds
        mostRecentBloomTime = now

        sprite.bloom(
            timeRequiredForFullBloom, color: pollenator.node.fillColor,
            scaleFactor: pollenator.node.xScale
        )
    }
}
