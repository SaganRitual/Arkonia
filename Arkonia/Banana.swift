import SpriteKit

class Banana {
    static func populateGarden(_ onComplete: @escaping () -> Void) {
        var cSown = 0

        func b() { (0..<Arkonia.cMannaMorsels).forEach { _ = Banana($0, c) } }

        func c() {
            cSown += 1
            if cSown >= Arkonia.cMannaMorsels { onComplete() }
        }

        b()
    }

    fileprivate struct Grid { }
    fileprivate struct Energy { }

    fileprivate struct Sprite {
        let sprite: SKSpriteNode

        init(_ fishNumber: Int) {
            let name = String(format: "manna-%05d", fishNumber)

            sprite = SpriteFactory.shared.mannaPool.makeSprite(name)

            sprite.userData![SpriteUserDataKey.setContentsCallback] = setContentsCallback
            sprite.userData![SpriteUserDataKey.bloomActionIx] = 0

            SpriteFactory.shared.mannaPool.attachSprite(sprite)
        }

        func setContentsCallback() {
            var bloomActionIx = (sprite.getKeyField(.bloomActionIx) as? Int)!
            sprite.run(Banana.Sprite.bloomActions[bloomActionIx])
            bloomActionIx = (bloomActionIx + 1) % Banana.Sprite.cBloomActions
            sprite.userData![SpriteUserDataKey.bloomActionIx] = bloomActionIx
        }

        func setManna(_ manna: Banana) {
            self.sprite.userData![SpriteUserDataKey.manna] = manna
        }
    }

    fileprivate let energy = Energy()
    fileprivate let fishNumber: Int
    fileprivate let grid = Grid()
    fileprivate var rebloomDelay = Arkonia.mannaInitialRebloomDelay
    fileprivate let sprite: Sprite

    fileprivate init(_ fishNumber: Int, _ onComplete: @escaping () -> Void) {
        self.fishNumber = fishNumber
        self.sprite = Sprite(fishNumber)

        self.sprite.setManna(self)
        sow(onComplete)
    }
}

extension Banana {
    func harvest(_ onComplete: @escaping (CGFloat) -> Void) {
        getNutritionInJoules { nutrition in
            GridCell.cPhotosynthesizingManna -= 1
            Debug.log(level: 111) {
                "harvest \(nutrition) joules from \(six(self.sprite.sprite.name))"
                + " at \(self.sprite.sprite.position);"
                + " c = \(GridCell.cPhotosynthesizingManna)"
                + " i = \(GridCell.cInjectedManna)"
            }

            self.sprite.reset()
            self.replant { onComplete(nutrition) }
        }
    }

    func floatManna(at cell: GridCell, hotKey: HotKey) {
        Substrate.serialQueue.async {
//            // We need the lock for the duration of this call, but the compiler
//            // gets pissed off if we don't use cellKey. Hence the two-line
//            // construction
//            let cellKey = cell.lock(require: .degradeToNil, ownerName: self.sprite.sprite.name!)
//            guard let hotKey = cell. as? HotKey else { fatalError() }

            GridCell.cPhotosynthesizingManna += 1
            Debug.log(level: 108) { "Banana.floatManna at \(cell.gridPosition); c = \(GridCell.cPhotosynthesizingManna)" }
            cell.setContents(to: .manna, newSprite: self.sprite.sprite)
            hotKey.releaseLock(serviceRequesters: false)
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

    fileprivate func sow(_ onComplete: @escaping () -> Void) {
        replant(cRetries: 5, onComplete)
    }

    private func replant(cRetries: Int = 0, _ onComplete: @escaping () -> Void) {
        var newHome: GridCell?
        var didPlant = false

        func a() {
            grid.plant(sprite.sprite, cRetries: cRetries) {
                newHome = $0; didPlant = $1; b()
            }
        }

        func b() {
            if didPlant { self.sprite.plant(at: newHome, onComplete) }
            else        { self.sprite.inject(at: newHome, onComplete) }
        }

        a()
    }
}

extension Banana.Grid {
    fileprivate func plant(
        _ sprite: SKSpriteNode,
        cRetries: Int = 0,
        _ onComplete: @escaping (GridCell, Bool) -> Void
    ) {
        var cell: GridCell!
        var hotKey: HotKey?

        Substrate.serialQueue.async {
            for _ in 0..<(cRetries + 1) where hotKey == nil {
                cell = GridCell.getRandomCell()

                if let hk = cell.lockIfEmpty(ownerName: sprite.name!) { hotKey = hk }
            }

            if hotKey == nil {
                GridCell.cInjectedManna += 1
                Debug.log(level: 112) { "inject \(six(sprite.name)) at \(cell.gridPosition); d = \(cell.dormantManna.count); c = \(GridCell.cPhotosynthesizingManna); i = \(GridCell.cInjectedManna)" }
                cell.injectManna(sprite)
            } else {
                GridCell.cPhotosynthesizingManna += 1
                Debug.log(level: 111) { "plant  \(six(sprite.name)) at \(cell.gridPosition); c = \(GridCell.cPhotosynthesizingManna); i = \(GridCell.cInjectedManna)" }
                cell.setContents(to: .manna, newSprite: sprite)
            }

            hotKey?.releaseLock(serviceRequesters: false)
            onComplete(cell, hotKey != nil)
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
    static let cBloomActions = 3
    static let bloomAction = SKAction.group([fadeInAction, colorAction])
    static let doomAction = SKAction.group([fadeInAction, dolorAction])
    static let eoomAction = SKAction.group([fadeInAction, eolorAction])

    private static let colorAction = SKAction.colorize(
        with: .blue, colorBlendFactor: Arkonia.mannaColorBlendMaximum,
        duration: Arkonia.mannaFullGrowthDurationSeconds
    )

    private static let dolorAction = SKAction.colorize(
        with: .red, colorBlendFactor: Arkonia.mannaColorBlendMaximum,
        duration: Arkonia.mannaFullGrowthDurationSeconds
    )

    private static let eolorAction = SKAction.colorize(
        with: .green, colorBlendFactor: Arkonia.mannaColorBlendMaximum,
        duration: Arkonia.mannaFullGrowthDurationSeconds
    )

    static let bloomActions = [ bloomAction, doomAction, eoomAction ]
    static let colorActions = [ colorAction, dolorAction, eolorAction ]

    static let fadeInAction = SKAction.fadeAlpha(
        to: 1, duration: Arkonia.mannaFullGrowthDurationSeconds
    )

    func getIndicatorFullness() -> CGFloat {
        // Sometimes the color blend factor ends up outside this range, which
        // botches the energy calculations when we eat the manna. I think it's
        // something to do with the way I'm running the actions, but I don't
        // feel like looking at it at the moment
        let top = constrain(
            sprite.colorBlendFactor,
            lo: Arkonia.mannaColorBlendMinimum,
            hi: Arkonia.mannaColorBlendMaximum
        )

        let width = abs(top - Arkonia.mannaColorBlendMinimum)
        let result = width / Arkonia.mannaColorBlendRangeWidth

        Debug.log("getIndicatorFullness t = \(top), w = \(width), r = \(result)", level: 82)
        return result
    }

    func inject(at cell: GridCell?, _ onComplete: @escaping () -> Void) {
        prep(at: cell)
        onComplete()
    }

    func plant(at cell: GridCell?, _ onComplete: @escaping () -> Void) {
        prep(at: cell)

        var bloomActionIx = (sprite.getKeyField(.bloomActionIx) as? Int)!
        let toRun = Banana.Sprite.bloomActions[bloomActionIx]
        bloomActionIx = (bloomActionIx + 1) % Banana.Sprite.cBloomActions
        sprite.userData![SpriteUserDataKey.bloomActionIx] = bloomActionIx

        sprite.run(toRun)
        onComplete()
    }

    private func prep(at cell: GridCell?) {
        sprite.setScale(Arkonia.mannaScaleFactor / Arkonia.zoomFactor)
        sprite.position = cell?.randomScenePosition ?? cell!.scenePosition
    }

    fileprivate func reset() {
        sprite.alpha = 0
        sprite.colorBlendFactor = Arkonia.mannaColorBlendMinimum
    }
}
