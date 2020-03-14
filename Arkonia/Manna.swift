import SpriteKit

extension Arkonia {
    static let cMannaReplant = 100
}

class Manna {
    struct MGrid { }
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

    fileprivate let energy = Energy()
    fileprivate let fishNumber: Int
    fileprivate let mGrid = MGrid()
    let sprite: Sprite

    init(_ fishNumber: Int) {
        self.fishNumber = fishNumber
        self.sprite = Sprite(fishNumber)
        self.sprite.setManna(self)
        self.sprite.reset()
    }

    func mark() {
        sprite.sprite.color = .green
    }
}

extension Manna {
    func harvest(_ onComplete: @escaping (CGFloat) -> Void) {

        var nutritionInJoules: CGFloat = 0

        func a() { getNutritionInJoules { nutritionInJoules = $0; b() } }

        func b() {
            GridCell.cPhotosynthesizingManna -= 1

            SceneDispatch.schedule(self.sprite.reset)
            MannaCannon.shared!.refurbishManna(self) { onComplete(nutritionInJoules) }
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
            onComplete(entropizedEnergyContentInJoules)
        }
    }

    func replant(_ onComplete: @escaping (Bool) -> Void) {
//            // Have 1% of the manna die off when it's eaten
//            if Int.random(in: 0..<100) == 0 && firstTime == false {
//                Clock.dispatchQueue.async { GridCell.cDeadManna += 1 }
//                return
//            }
        Debug.log(level: 124) { "replant.1" }

        let (newHome, didPlant) = mGrid.plant(sprite.sprite)
        Debug.log(level: 124) { "replant.2" }

        if didPlant { self.sprite.plant(at: newHome) }
        onComplete(didPlant)
    }
}
