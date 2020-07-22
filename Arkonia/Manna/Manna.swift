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

        MannaCannon.mannaPlaneQueue.async {
            MannaCannon.shared!.cPhotosynthesizingManna -= 1
        }

        Clock.dispatchQueue.async {
            let temperature = SeasonalFactors(Clock.shared.worldClock).normalizedSunstickHeight

            let mannaContent = EnergyBudget.MannaContent(maturityLevel, temperature)

            Debug.log(level: 218) {
                "harvest at \(self.absoluteGridIndex):"
                + " maturity \(maturityLevel) * temperature \(temperature)"
                + " = \(maturityLevel * temperature)"
                + " -> ham \(mannaContent.selectStore(.energy)!)"
            }

            SceneDispatch.shared.schedule(self.rebloom)
            mainDispatch { onComplete(mannaContent) }
        }
    }

    func rebloom() {
        hardAssert(Display.displayCycle == .updateStarted) { "hardAssert at \(#file):\(#line)" }

        sprite.reset()

        // Check for pollenators above me; if none, go back to sleep for a while
        let mc = MannaCannon.shared!

        guard let pollenator = mc.pollenators.first(
            where: { $0.node.contains(sprite.sprite.position) }
        ) else { mc.blast(self); return }

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

        Debug.log(level: 217) { "rebloom at \(absoluteGridIndex); timeRequiredForFullBloom = \(timeRequiredForFullBloom)" }
        let node = pollenator.node
        sprite.bloom(timeRequiredForFullBloom, color: node.fillColor, scaleFactor: node.xScale)
    }
}
