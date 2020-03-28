import SpriteKit

class Manna {
    struct Energy { }

    struct Sprite {
        let sprite: SKSpriteNode

        init(_ fishNumber: Int) {
            let name = String(format: "manna-%05d", fishNumber)

            sprite = SpriteFactory.shared.mannaPool.makeSprite(name)

            sprite.userData![SpriteUserDataKey.setContentsCallback] = setContentsCallback
            sprite.userData![SpriteUserDataKey.bloomActionIx] = 0

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
        self.sprite.setManna(self)
        self.sprite.reset()
    }
}

extension Manna {
    func harvest(_ onComplete: @escaping (CGFloat) -> Void) {
        var nutritionInJoules: CGFloat = 0

        func a() { getNutritionInJoules { nutritionInJoules = $0; b() } }

        func b() {
            if nutritionInJoules < (0.25 * Arkonia.maxMannaEnergyContentInJoules) { onComplete(0); return }

            MannaCannon.shared!.rebloomDispatch.async { MannaCannon.shared!.cPhotosynthesizingManna -= 1 }

            self.rebloom(c)
        }

        func c() { onComplete(nutritionInJoules) }

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
        guard cell.mannaSprite == nil else { return false }

        cell.mannaSprite = self.sprite.sprite
        self.sprite.bloom(at: cell)
        return true
    }

    enum RebloomResult { case died, rebloomed }

    func rebloom(_ onComplete: @escaping () -> Void) {
        sprite.reset()
        onComplete()

        // Have 1% of the manna die off when it's eaten
        if Int.random(in: 0..<100) > 0 {
            sprite.rebloom()
            return
        }

        MannaCannon.shared!.rebloomDispatch.async { MannaCannon.shared!.cDeadManna += 1 }
    }
}
