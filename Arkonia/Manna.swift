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
        var didPlant = false
        var newHome: GridCell?
        var toNextRain: TimeInterval = 0

        func a() {
            Clock.dispatchQueue.async {
                if let nextRain = Clock.shared?.nextRain {
                    toNextRain = max(0, Date().distance(to: nextRain))
                }

                b()
            }
        }

        func b() {
            let fudge = TimeInterval.random(in: 0.5..<1)
            let when = DispatchWallTime.now() + toNextRain + fudge
            Grid.serialQueue.asyncAfter(wallDeadline: when, execute: c)
        }

        func c() {
            (newHome, didPlant) = mGrid.plant(sprite.sprite)
            if didPlant { self.sprite.plant(at: newHome); return }

            let fudge = TimeInterval.random(in: 0.5..<1)
            let when = DispatchWallTime.now() + fudge
            Grid.serialQueue.asyncAfter(wallDeadline: when, execute: c)
        }

        a()
    }

    fileprivate func sow() { replant(firstTime: true) }
}
