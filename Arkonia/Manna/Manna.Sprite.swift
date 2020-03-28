import SpriteKit

extension Manna.Sprite {
    static let cBloomActions = 3
    static let firstBloomAction = SKAction.group([firstFadeInAction, firstColorAction])
    static let bloomAction = SKAction.group([fadeInAction, colorAction])
    static let doomAction = SKAction.group([fadeInAction, dolorAction])
    static let eoomAction = SKAction.group([fadeInAction, eolorAction])

    private static let firstColorAction = SKAction.colorize(
        with: .blue, colorBlendFactor: Arkonia.mannaColorBlendMaximum,
        duration: 0.01
    )

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

    static let firstFadeInAction = SKAction.fadeAlpha(
        to: 0.5, duration: 0.01
    )

    static let fadeInAction = SKAction.fadeAlpha(
        to: 0.5, duration: Arkonia.mannaFullGrowthDurationSeconds
    )

    var isPhotosynthesizing: Bool {
        sprite.colorBlendFactor > Arkonia.mannaColorBlendMinimum
    }

    func bloom(at cell: GridCell?) {
        if cell != nil { prepForFirstPlanting(at: cell) }

        if MannaCannon.shared?.fertileSpots.first(
            where: { $0.node.contains(sprite.position) }
        ) == nil {
            let duration = TimeInterval.random(in: 1..<5)
            MannaCannon.shared!.rebloomDispatch.asyncAfter(deadline: .now() + duration) { self.bloom(at: nil) }
            return
        }

        // No need to wait for this, the count doesn't have to be
        // accurate; it's for display purposes only
        MannaCannon.shared!.rebloomDispatch.async { MannaCannon.shared!.cPhotosynthesizingManna += 1 }

        // We get non-nil cell only on the first time through, which is the
        // only time we get an instant bloom
        let toRun = (cell == nil) ? Manna.Sprite.bloomActions[bloomActionIx] : Manna.Sprite.firstBloomAction
        bloomActionIx = (bloomActionIx + 1) % Manna.Sprite.cBloomActions

        // Ok to let this run independently of the caller's thread, we don't
        // need anything from it, so there's no need to wait for completion
        sprite.run(toRun)
    }

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

        Debug.log(level: 154) { "getIndicatorFullness t = \(top), w = \(width), r = \(result)" }
        return result
    }

    private func prepForFirstPlanting(at cell: GridCell?) {
        sprite.setScale(Arkonia.mannaScaleFactor / Arkonia.zoomFactor)
        sprite.position = cell?.randomScenePosition ?? cell!.scenePosition
    }

    static var nextBloom: TimeInterval = 0.05
    func rebloom() {
//        let duration = TimeInterval.random(
//            in: Arkonia.mannaRebloomDelayMinimum..<Arkonia.mannaRebloomDelayMaximum
//        )

        MannaCannon.shared!.rebloomDispatch.asyncAfter(deadline: .now() + Manna.Sprite.nextBloom) {
            Manna.Sprite.nextBloom += 0.05
            if Manna.Sprite.nextBloom >= 1.0 { Manna.Sprite.nextBloom = 0.05 }
            self.bloom(at: nil)
        }
    }

    func reset() {
        sprite.removeAllActions()
        sprite.alpha = 0
        sprite.color = .black
        sprite.colorBlendFactor = Arkonia.mannaColorBlendMinimum
    }
}
