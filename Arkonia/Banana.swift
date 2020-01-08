import SpriteKit

class Banana {
    static private let dispatchQueue = DispatchQueue(
        label: "arkon.banana.q", target: DispatchQueue.global(qos: .default)
    )

    static func populateGarden() {
        func a(_ fishNumber: Int) { dispatchQueue.async { b(fishNumber) } }

        func b(_ fishNumber: Int) {
            if fishNumber >= Arkonia.cMannaMorsels { return }

            _ = Banana(fishNumber) { a(fishNumber + 1) }
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
    }

    fileprivate let energy = Energy()
    fileprivate let fishNumber: Int
    fileprivate let sprite: Sprite
    fileprivate let grid = Grid()

    fileprivate init(_ fishNumber: Int, _ onComplete: @escaping () -> Void) {
        self.fishNumber = fishNumber
        self.sprite = Sprite(fishNumber)
        self.sprite.sprite.userData![SpriteUserDataKey.manna] = self

        sow(onComplete)
    }
}

extension Banana {
    func harvest(_ onComplete: @escaping (CGFloat) -> Void) {
        harvestIf(onComplete)
    }

    func getNutritionInJoules(_ onComplete: @escaping (CGFloat) -> Void) {
        harvestIf(dryRun: true, onComplete)
    }

    private func harvestIf(dryRun: Bool = false, _ onComplete: @escaping (CGFloat) -> Void) {
        var cell: HotKey!
        var entropizedEnergyContentInJoules: CGFloat = 0

        func a() { grid.lockCell(sprite.sprite) { cell = $0; b() } }

        func b() {
            let f = sprite.getIndicatorFullness()
            let e = self.energy.getEnergyContentInJoules(f)
            Clock.shared.entropize(e) { entropizedEnergyContentInJoules = $0; c() }
        }

        func c() {
            if dryRun == false {
                sprite.plant(at: cell)
                sprite.reset()
            }

            onComplete(entropizedEnergyContentInJoules)
        }

        a()
    }

    fileprivate func sow(_ onComplete: @escaping () -> Void) {
        var cell: HotKey!

        func a() { grid.lockCell(sprite.sprite) { cell = $0; b() } }

        func b() {
            self.sprite.plant(at: cell)
            self.sprite.reset()
            onComplete()
        }

        a()
    }

}

extension Banana.Grid {
    func lockCell(_ sprite: SKSpriteNode, _ onComplete: @escaping (HotKey?) -> Void) {
        GridCell.lockRandomEmptyCell(ownerName: sprite.name!) { cell in
            cell!.contents = .manna
            cell!.sprite = sprite
            onComplete(cell)
        }
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
    static let bloomAction = SKAction.group([fadeInAction, colorAction])

    private static let colorAction = SKAction.colorize(
        with: .blue, colorBlendFactor: Arkonia.mannaColorBlendMaximum,
        duration: Arkonia.mannaFullGrowthDurationSeconds
    )

    static let fadeInAction = SKAction.fadeIn(withDuration: 1)

    func getIndicatorFullness() -> CGFloat {
        let top = max(sprite.colorBlendFactor, Arkonia.mannaColorBlendMinimum)
        let width = abs(top - Arkonia.mannaColorBlendMinimum)
        return width / Arkonia.mannaColorBlendRangeWidth
    }

    func plant(at cell: HotKey) {
        sprite.position = cell.randomScenePosition ?? cell.scenePosition
        sprite.setScale(Arkonia.mannaScaleFactor / Arkonia.zoomFactor)

        sprite.run(Banana.Sprite.bloomAction)
    }

    func reset() {
        sprite.alpha = 0
        sprite.colorBlendFactor = Arkonia.mannaColorBlendMinimum
    }
}
