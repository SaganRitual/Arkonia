import SpriteKit

class Manna {
    fileprivate var timeRequiredForFullBloom = Arkonia.mannaFullGrowthDurationSeconds
    fileprivate let fishNumber: Int
    fileprivate var mostRecentBloomTime: Date
    let sprite: Manna.Sprite

    var isPhotosynthesizing: Bool { self.sprite.isPhotosynthesizing }

    init(_ fishNumber: Int) {
        self.fishNumber = fishNumber
        self.sprite = Manna.Sprite(fishNumber)
        self.sprite.reset()

        // Set our date to the past so we'll treat the first bloom as completed already
        self.mostRecentBloomTime = Date() - Arkonia.mannaFullGrowthDurationSeconds
    }
}

extension Manna {
    class Nutrition {
        internal init(
            _ bone: CGFloat, _ ham: CGFloat, _ leather: CGFloat,
            _ oxygen: CGFloat, _ poison: CGFloat
        ) {
            self.bone = bone
            self.ham = ham
            self.leather = leather
            self.oxygen = oxygen
            self.poison = poison
        }

        let bone: CGFloat
        let ham: CGFloat
        let leather: CGFloat
        let oxygen: CGFloat
        let poison: CGFloat
    }
}

extension Manna {
    class Sprite {
        weak var gridCell: GridCell?
        let sprite: SKSpriteNode

        init(_ fishNumber: Int) {
            let name = ArkonName.makeMannaName(fishNumber)

            sprite = SpriteFactory.shared.mannaPool.makeSprite(name)

            SpriteFactory.shared.mannaPool.attachSprite(sprite)
        }
    }
}

extension Manna {
    func harvest(_ onComplete: @escaping (Nutrition?) -> Void) {
        func a() { getNutrition(b) }

        func b(_ nutrition: Nutrition) {
            // Don't give up any nutrition at all until I've bloomed enough
            if nutrition.ham < (0.25 * Arkonia.maxMannaEnergyContentInJoules) { onComplete(nil); return }

            MannaCannon.mannaPlaneQueue.async { MannaCannon.shared!.cPhotosynthesizingManna -= 1 }

            sprite.gridCell!.mannaAwaitingRebloom = true

            Dispatch.dispatchQueue.async { onComplete(nutrition) }
        }

        a()
    }

    func getEnergyContentInJoules() -> CGFloat {
        let indicatorFullness = sprite.getIndicatorFullness()
        let rate = Arkonia.mannaGrowthRateJoulesPerSecond
        let duration = CGFloat(Arkonia.mannaFullGrowthDurationSeconds)

        let energyContent: CGFloat = indicatorFullness * rate * duration
        Debug.log(level: 136) { "energy content \(energyContent)" }
        return energyContent
    }

    func getNutrition(_ onComplete: @escaping (Nutrition) -> Void) {
        let e = getEnergyContentInJoules()

        // If there's no time limit, then cosmic entropy is n/a, doesn't happen
        if Arkonia.worldTimeLimit == nil {
            let nutrition = Nutrition(1, e, 1, e, 1 )
            onComplete(nutrition)
            return
        }

        Clock.shared.entropize(e) { entropizedEnergyContentInJoules in
            Dispatch.dispatchQueue.async {
                let nutrition = Nutrition(
                    1, entropizedEnergyContentInJoules,
                    1, entropizedEnergyContentInJoules, 1
                )

                onComplete(nutrition)
            }
        }
    }

    func plant() -> Bool {
        let cell = GridCell.getRandomCell()
        guard cell.manna == nil else { return false }

        Debug.log(level: 156) { "plant \(self.fishNumber) at \(cell.gridPosition)" }
        cell.manna = self
        self.sprite.firstBloom(at: cell)
        return true
    }

    enum RebloomResult { case died, rebloomed }

    func rebloom() {
        sprite.reset()

        // Check for pollenators above me; if none, go back to sleep for a while
        guard let fs = MannaCannon.shared?.pollenators.first(
            where: { $0.node.contains(sprite.sprite.position) }
        ) else { MannaCannon.shared!.blast(self); return }

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

        #if DEBUG
        Debug.log(level: 171) { "rebloom \(growthDuration), \(maturity), \(catchup), \(timeRequiredForFullBloom)" }
        #endif

        sprite.bloom(timeRequiredForFullBloom, color: fs.node.fillColor, scaleFactor: fs.node.xScale)
    }
}

extension Debug {
    static func showMannaStats() {
        var cCells = 0, cPhotosynthesizing = 0

        for x in -Grid.shared.gridWidthInCells..<Grid.shared.gridWidthInCells {
            for y in -Grid.shared.gridHeightInCells..<Grid.shared.gridHeightInCells {
                let p = AKPoint(x: x, y: y)
                let c = Grid.shared.getCell(at: p)

                cCells += 1

                guard let manna = c.manna else {
                    continue
                }

                cPhotosynthesizing += manna.isPhotosynthesizing ? 1 : 0
            }
        }

        print("Manna stats; \(cCells) cells, \(cPhotosynthesizing) photosynthesizing")
    }
}