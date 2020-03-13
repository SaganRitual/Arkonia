import SpriteKit

extension Manna.MGrid {
    func plant(_ sprite: SKSpriteNode) -> (GridCell, Bool) {
        let cell = GridCell.getRandomCell()

        guard GriddleScene.shared.fertileSpot.node.contains(cell.scenePosition)
            else { return (cell, false) }

        guard let hotKey = cell.lockIfEmpty(ownerName: sprite.name!)
            else { return (cell, false) }

        Clock.dispatchQueue.async { GridCell.cPhotosynthesizingManna += 1 }  // Because laziness
        Debug.log(level: 111) { "plant  \(six(sprite.name)) at \(cell.gridPosition); c = \(GridCell.cPhotosynthesizingManna)" }
        cell.setContents(to: .manna, newSprite: sprite)

        hotKey.releaseLock(serviceRequesters: false)
        return (cell, true)
    }
}

extension Manna.Energy {
    func getEnergyContentInJoules(_ indicatorFullness: CGFloat) -> CGFloat {
        let rate = Arkonia.mannaGrowthRateJoulesPerSecond
        let duration = CGFloat(Arkonia.mannaFullGrowthDurationSeconds)

        let energyContent: CGFloat = indicatorFullness * rate * duration
        return energyContent
    }
}

extension Manna.Sprite {
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

        Debug.log(level: 82) { "getIndicatorFullness t = \(top), w = \(width), r = \(result)" }
        return result
    }

    func plant(at cell: GridCell?) {
        prep(at: cell)

        var bloomActionIx = (sprite.getKeyField(.bloomActionIx) as? Int)!
        let toRun = Manna.Sprite.bloomActions[bloomActionIx]
        bloomActionIx = (bloomActionIx + 1) % Manna.Sprite.cBloomActions
        sprite.userData![SpriteUserDataKey.bloomActionIx] = bloomActionIx

        sprite.run(toRun)
    }

    private func prep(at cell: GridCell?) {
        sprite.setScale(Arkonia.mannaScaleFactor / Arkonia.zoomFactor)
        sprite.position = cell?.randomScenePosition ?? cell!.scenePosition
    }

    func reset() {
        sprite.alpha = 0
        sprite.colorBlendFactor = Arkonia.mannaColorBlendMinimum
    }

    func setContentsCallback() {
        var bloomActionIx = (sprite.getKeyField(.bloomActionIx) as? Int)!
        sprite.run(Manna.Sprite.bloomActions[bloomActionIx])
        bloomActionIx = (bloomActionIx + 1) % Manna.Sprite.cBloomActions
        sprite.userData![SpriteUserDataKey.bloomActionIx] = bloomActionIx
    }

    func setManna(_ manna: Manna) {
        self.sprite.userData![SpriteUserDataKey.manna] = manna
    }
}
