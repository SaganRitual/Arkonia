import SpriteKit

class Manna {
    static func populateGarden() {
        (0..<Arkonia.cMannaMorsels).forEach { _ = Manna($0) }
    }

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
    fileprivate var rebloomDelay = Arkonia.mannaInitialRebloomDelay
    fileprivate let sprite: Sprite

    fileprivate init(_ fishNumber: Int) {
        self.fishNumber = fishNumber
        self.sprite = Sprite(fishNumber)

        self.sprite.setManna(self)
        sow()
    }
}

extension Manna {
    func harvest(_ onComplete: @escaping (CGFloat) -> Void) {
        getNutritionInJoules { nutrition in
            GridCell.cPhotosynthesizingManna -= 1
            Debug.log(level: 111) {
                "harvest \(nutrition) joules from \(six(self.sprite.sprite.name))"
                + " at \(self.sprite.sprite.position);"
                + " c = \(GridCell.cPhotosynthesizingManna)"
            }

            self.rebloomDelay += Arkonia.mannaRebloomDelayIncrement
            self.sprite.reset()
            self.replant()
            onComplete(nutrition)
        }
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

    private func replant(firstTime: Bool = false) {
        var newHome: GridCell?
        var didPlant = false

        func a() { Grid.serialQueue.async(execute: b) }

        func b() {
            (newHome, didPlant) = mGrid.plant(sprite.sprite)

            if didPlant { self.sprite.plant(at: newHome); return }

            Grid.serialQueue.asyncAfter(deadline: .now() + rebloomDelay, execute: b)
        }

        a()
    }

    fileprivate func sow() { replant(firstTime: true) }
}
