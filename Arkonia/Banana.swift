import SpriteKit

class Banana {
    static private let dispatchQueue = DispatchQueue(
        label: "arkon.banana.q", target: DispatchQueue.global(qos: .userInitiated)
    )

    static func populateGarden(_ onComplete: @escaping () -> Void) {
        var cSown = 0

        func a(_ fruitNumber: Int) { dispatchQueue.async { b(fruitNumber) } }

        func b(_ fruitNumber: Int) {
            for frootNumber in 0..<Arkonia.cMannaMorsels {
                _ = Banana(frootNumber, c)
            }
        }

        func c() {
            cSown += 1
            if cSown >= Arkonia.cMannaMorsels { onComplete() }
        }

        a(0)
    }

    fileprivate struct Grid { }
    fileprivate struct Energy { }

    fileprivate struct Sprite {
        let sprite: SKSpriteNode

        init(_ fishNumber: Int) {
            let name = "manna-\(fishNumber)"

            sprite = SpriteFactory.shared.mannaHangar.makeSprite(name)
            GriddleScene.arkonsPortal!.addChild(sprite)
        }

        func setManna(_ manna: Banana) {
            self.sprite.userData![SpriteUserDataKey.manna] = manna
        }
    }

    fileprivate let energy = Energy()
    fileprivate let fishNumber: Int
    fileprivate let sprite: Sprite
    fileprivate let grid = Grid()

    fileprivate init(_ fishNumber: Int, _ onComplete: @escaping () -> Void) {
        self.fishNumber = fishNumber
        self.sprite = Sprite(fishNumber)

        self.sprite.setManna(self)
        sow(onComplete)
    }
}

extension Banana {
    func harvest(_ onComplete: @escaping (CGFloat) -> Void) {
        harvestIf { entropizedEnergyContentInJoules in
            Debug.log("Harvested \(entropizedEnergyContentInJoules)", level: 78)
            onComplete(entropizedEnergyContentInJoules)
        }
    }

    func getNutritionInJoules(_ onComplete: @escaping (CGFloat) -> Void) {
        harvestIf(dryRun: true, onComplete)
    }

    private func harvestIf(dryRun: Bool = false, _ onComplete: @escaping (CGFloat) -> Void) {
        var cell: GridCell!
        var entropizedEnergyContentInJoules: CGFloat = 0

        func a() { GridCell.getRandomEmptyCell { cell = $0; b() } }

        func b() {
            let f = sprite.getIndicatorFullness()
            let e = self.energy.getEnergyContentInJoules(f)
            Clock.shared.entropize(e) { entropizedEnergyContentInJoules = $0; c() }
        }

        func c() {
            if dryRun { d(); return }

            sprite.reset()
            sprite.plant(at: cell, d)
        }

        func d() { onComplete(entropizedEnergyContentInJoules) }

        a()
    }

    fileprivate func sow(_ onComplete: @escaping () -> Void) {
        grid.plant(sprite.sprite) {
            guard let cell = $0 else { onComplete(); return }
            self.sprite.plant(at: cell, onComplete)
        }
    }

}

extension Banana.Grid {
    func plant(_ sprite: SKSpriteNode, _ onComplete: @escaping (GridCell?) -> Void) {

        var cell: GridCell!

        func a() { Substrate.serialQueue.async(execute: b) }
        func b() { cell = GridCell.getRandomCell(); c() }
        func c() { if cell.contents.isOccupied { isOccupied() } else { notOccupied() } }

        func isOccupied() {
            sprite.userData!["barf"] = true
            cell.injectManna(sprite)
            onComplete(nil)
        }

        func notOccupied() {
            cell.setContents(to: .manna, newSprite: sprite, f)
        }

        func f() { onComplete(cell) }

        a()
    }
}

extension Banana.Energy {
    func getEnergyContentInJoules(_ indicatorFullness: CGFloat) -> CGFloat {
        let rate = Arkonia.mannaGrowthRateJoulesPerSecond
        let duration = CGFloat(Arkonia.mannaFullGrowthDurationSeconds)

        let energyContent: CGFloat = indicatorFullness * rate * duration
        return energyContent
    }
}

extension Banana.Sprite {
    static var debug = true
    static let bloomAction = SKAction.group([fadeInAction, colorAction])
    static let doomAction = SKAction.group([fadeInAction, dolorAction])
    static let eoomAction = SKAction.group([fadeInAction, eolorAction])

    private static let colorAction = SKAction.colorize(
        with: .green, colorBlendFactor: Arkonia.mannaColorBlendMaximum,
        duration: Arkonia.mannaFullGrowthDurationSeconds
    )

    private static let dolorAction = SKAction.colorize(
        with: .blue, colorBlendFactor: Arkonia.mannaColorBlendMaximum,
        duration: Arkonia.mannaFullGrowthDurationSeconds
    )

    private static let eolorAction = SKAction.colorize(
        with: .red, colorBlendFactor: Arkonia.mannaColorBlendMaximum,
        duration: Arkonia.mannaFullGrowthDurationSeconds
    )

    static let fadeInAction = SKAction.fadeIn(withDuration: 1)

    func getIndicatorFullness() -> CGFloat {
        let top = max(sprite.colorBlendFactor, Arkonia.mannaColorBlendMinimum)
        let width = abs(top - Arkonia.mannaColorBlendMinimum)
        return width / Arkonia.mannaColorBlendRangeWidth
    }

    func plant(at cell: GridCell, _ onComplete: @escaping () -> Void) {
        sprite.position = cell.randomScenePosition ?? cell.scenePosition
        sprite.setScale(Arkonia.mannaScaleFactor / Arkonia.zoomFactor)

        let a: SKAction
        if Banana.Sprite.debug {
            a = Banana.Sprite.bloomAction
        } else {
            if sprite.userData?["barf"] == nil { a = Banana.Sprite.doomAction }
            else { a = Banana.Sprite.eoomAction; sprite.xScale *= 5; sprite.yScale *= 5 }
        }

        sprite.run(a)
        onComplete()
    }

    func reset() {
        Banana.Sprite.debug = false
        sprite.alpha = 0
        sprite.colorBlendFactor = Arkonia.mannaColorBlendMinimum
    }
}
