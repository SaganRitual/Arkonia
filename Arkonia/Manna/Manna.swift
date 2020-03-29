import SpriteKit

class Manna {
    struct Energy { }

    class Sprite {
        var bloomActionIx = 0
        weak var gridCell: GridCell?
        let sprite: SKSpriteNode

        init(_ fishNumber: Int) {
            let name = String(format: "manna-%05d", fishNumber)

            sprite = SpriteFactory.shared.mannaPool.makeSprite(name)

            SpriteFactory.shared.mannaPool.attachSprite(sprite)
        }
    }

    fileprivate let energy = Manna.Energy()
    fileprivate let fishNumber: Int
    let sprite: Manna.Sprite

    var isPhotosynthesizing: Bool { self.sprite.isPhotosynthesizing }

    init(_ fishNumber: Int) {
        self.fishNumber = fishNumber
        self.sprite = Manna.Sprite(fishNumber)
        self.sprite.reset()
    }
}

extension Manna {
    func harvest(_ onComplete: @escaping (CGFloat) -> Void) {
        var nutritionInJoules: CGFloat = 0

        func a() { getNutritionInJoules { nutritionInJoules = $0; b() } }

        func b() {
            if nutritionInJoules < (0.25 * Arkonia.maxMannaEnergyContentInJoules) { onComplete(0); return }

            MannaCannon.shared!.diebackDispatch.async { MannaCannon.shared!.cPhotosynthesizingManna -= 1 }

            sprite.gridCell!.mannaAwaitingRebloom = true
            onComplete(nutritionInJoules)
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
            onComplete(entropizedEnergyContentInJoules)
        }
    }

    func plant() -> Bool {
        let cell = GridCell.getRandomCell()
        guard cell.manna == nil else { return false }

        Debug.log(level: 156) { "plant \(self.fishNumber) at \(cell.gridPosition)" }
        cell.manna = self
        self.sprite.bloom(at: cell, color: .blue)
        return true
    }

    enum RebloomResult { case died, rebloomed }

    func rebloom() {
        sprite.reset()

        // Have 1% of the manna die off when it's eaten
        if Int.random(in: 0..<100) == 0 {
            MannaCannon.shared!.diebackDispatch.async { MannaCannon.shared!.cDeadManna += 1 }
            return
        }

        guard let fs = MannaCannon.shared?.pollenators.first(
            where: { $0.node.contains(sprite.sprite.position) }
        ) else { MannaCannon.shared!.blast(self); return }

        sprite.bloom(at: nil, color: fs.node.strokeColor)
    }
}
