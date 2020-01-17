import SpriteKit

class Banana {
    static private let dispatchQueue = DispatchQueue(
        label: "arkon.banana.q", target: DispatchQueue.global(qos: .userInitiated)
    )

    static func populateGarden(_ onComplete: @escaping () -> Void) {
        var cSown = 0

        func a() { dispatchQueue.async(execute: b) }

        func b() { (0..<Arkonia.cMannaMorsels).forEach { _ = Banana($0, c) } }

        func c() {
            cSown += 1
            if cSown >= Arkonia.cMannaMorsels { onComplete() }
        }

        a()
    }

    fileprivate struct Grid { }
    fileprivate struct Energy { }

    fileprivate struct Sprite {
        let sprite: SKSpriteNode

        init(_ fishNumber: Int) {
            let name = "manna-\(fishNumber)"

            sprite = SpriteFactory.shared.mannaHangar.makeSprite(name)
            sprite.colorBlendFactor = Arkonia.mannaColorBlendMinimum

            sprite.userData![SpriteUserDataKey.setContentsCallback] = setContentsCallback
            sprite.userData![SpriteUserDataKey.bloomActionIx] = 0

            sprite.zPosition = 4
            GriddleScene.mannaPortal!.addChild(sprite)
        }

        func setContentsCallback() {
            Debug.log("setContentsCallback \(sprite.position)", level: 86)
            var bloomActionIx = (sprite.getKeyField(.bloomActionIx) as? Int)!
            sprite.run(Banana.Sprite.bloomActions[bloomActionIx])
            bloomActionIx = (bloomActionIx + 1) % 3
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
        getNutritionInJoules {
            Debug.log("harvest", level: 85)

            self.sprite.reset()
            onComplete($0)

            self.replant()
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

    func replant() {
        var newHome: GridCell!
        var didPlant = false

        func a() { Banana.dispatchQueue.asyncAfter(deadline: .now() + rebloomDelay, execute: b) }

        func b() {
            sprite.reset()
            grid.plant(sprite.sprite) { newHome = $0; didPlant = $1; c() }
        }

        func c() {
            if didPlant { self.sprite.plant(at: newHome, d) }
            else        { self.sprite.inject(at: newHome, d) }
        }

        func d() { rebloomDelay += 0.1 }

        Debug.log("harvest", level: 85)
        a()
    }

    fileprivate func sow(_ onComplete: @escaping () -> Void) {
        var newHome: GridCell!
        var didPlant = false

        func a() { grid.plant(sprite.sprite) { newHome = $0; didPlant = $1; b() } }

        func b() {
            if didPlant { self.sprite.plant(at: newHome, onComplete) }
            else        { self.sprite.inject(at: newHome, onComplete) }
        }

        a()
    }
}

extension Banana.Grid {
    fileprivate func plant(_ sprite: SKSpriteNode, _ onComplete: @escaping (GridCell, Bool) -> Void) {
        var cell: GridCell!

        func a() { Substrate.serialQueue.async(execute: b) }
        func b() { cell = GridCell.getRandomCell(); c() }
        func c() { if cell.contents.isOccupied { isOccupied() } else { isNotOccupied() } }

        func isOccupied() {
            Debug.log("inject \(six(sprite.name)) at \(cell.gridPosition)", level: 83)
            cell.injectManna(sprite)
            onComplete(cell, false)
        }

        func isNotOccupied() {
            cell.setContents(to: .manna, newSprite: sprite) { onComplete(cell, true) }
        }

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
        with: .blue, colorBlendFactor: Arkonia.mannaColorBlendMaximum,
        duration: Arkonia.mannaFullGrowthDurationSeconds
    )

    private static let dolorAction = SKAction.colorize(
        with: .red, colorBlendFactor: Arkonia.mannaColorBlendMaximum,
        duration: Arkonia.mannaFullGrowthDurationSeconds
    )

    private static let eolorAction = SKAction.colorize(
        with: .yellow, colorBlendFactor: Arkonia.mannaColorBlendMaximum,
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
        bloomActionIx = (bloomActionIx + 1) % 3
        sprite.userData![SpriteUserDataKey.bloomActionIx] = bloomActionIx

        sprite.run(toRun)
        onComplete()
    }

    private func prep(at cell: GridCell?) {
        sprite.setScale(Arkonia.mannaScaleFactor / Arkonia.zoomFactor)
        sprite.position = cell?.randomScenePosition ?? cell!.scenePosition
    }

    fileprivate func reset() {
        Banana.Sprite.debug = false
        sprite.alpha = 0
        sprite.colorBlendFactor = Arkonia.mannaColorBlendMinimum
    }
}
