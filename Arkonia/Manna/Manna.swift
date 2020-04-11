import SpriteKit

class Manna {
    struct Energy { }

    class Sprite {
        var bloomActionIx = 0
        weak var gridCell: GridCell?
        let sprite: SKSpriteNode

        init(_ fishNumber: Int) {
            let name = ArkonName.makeMannaName(fishNumber)

            sprite = SpriteFactory.shared.mannaPool.makeSprite(name)

            SpriteFactory.shared.mannaPool.attachSprite(sprite)
        }
    }

    fileprivate let energy = Manna.Energy()
    fileprivate var entropyFactor = Arkonia.selectionPressureFactor
    fileprivate let fishNumber: Int
    fileprivate var mostRecentBloomTime: Date
    let sprite: Manna.Sprite

    var isPhotosynthesizing: Bool { self.sprite.isPhotosynthesizing }

    init(_ fishNumber: Int) {
        self.fishNumber = fishNumber
        self.mostRecentBloomTime = Date()
        self.sprite = Manna.Sprite(fishNumber)
        self.sprite.reset()
    }
}

extension Manna {
    func harvest(_ onComplete: @escaping (CGFloat) -> Void) {
        var nutritionInJoules: CGFloat = 0

        func a() { getNutritionInJoules { nutritionInJoules = $0; b() } }

        func b() {
            defer {
                Dispatch.dispatchQueue.async { onComplete(nutritionInJoules) }
            }

            // Don't give up any nutrition at all until I've bloomed enough
            if nutritionInJoules < (0.25 * Arkonia.maxMannaEnergyContentInJoules) { nutritionInJoules = 0; return }

            MannaCannon.mannaPlaneQueue.async { MannaCannon.shared!.cPhotosynthesizingManna -= 1 }

            sprite.gridCell!.mannaAwaitingRebloom = true
        }

        a()
    }

    func getEnergyContentInJoules() -> CGFloat {
        let f = sprite.getIndicatorFullness()
        precondition(floor(f) <= 1.0)   // floor() because we get rounding errors sometimes

        return self.energy.getEnergyContentInJoules(f)
    }

    func getNutritionInJoules(_ onComplete: @escaping (CGFloat) -> Void) {
        let e = getEnergyContentInJoules()

        Clock.shared.entropize(e) { entropizedEnergyContentInJoules in
            Debug.log(level: 154) { "getNutritionInJoules \(entropizedEnergyContentInJoules)" }

            Dispatch.dispatchQueue.async { onComplete(entropizedEnergyContentInJoules) }
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

//        // Have 1% of the manna die off when it's eaten
//        if Int.random(in: 0..<100) < 1 {
//            MannaCannon.mannaPlaneQueue.async { MannaCannon.shared!.cDeadManna += 1 }
//            return
//        }

        guard let fs = MannaCannon.shared?.pollenators.first(
            where: { $0.node.contains(sprite.sprite.position) }
        ) else { MannaCannon.shared!.blast(self); return }

        let now = Date()
        let growthDuration = mostRecentBloomTime.distance(to: now)

        let maturity = min(
            1,
            growthDuration / (self.entropyFactor * Arkonia.mannaFullGrowthDurationSeconds)
        )

        // We get a bit more tired each time we're grazed, such that reaching
        // nutritional maturity takes a bit longer every time
        self.entropyFactor *= 2

        sprite.bloom(maturity: maturity, color: fs.node.fillColor, scaleFactor: fs.node.xScale)
    }
}
