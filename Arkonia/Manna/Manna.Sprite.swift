import SpriteKit

extension Manna.Sprite {
    static let firstBloomAction = SKAction.group([firstFadeInAction, firstColorAction])

    private static let firstColorAction = SKAction.colorize(
        with: .blue, colorBlendFactor: Arkonia.mannaColorBlendMaximum,
        duration: 0.01
    )

    private static func bloomAction(
        _ timeRequiredForFullBloom: TimeInterval,
        _ color: SKColor,
        _ scaleFactor: CGFloat? = nil
    ) -> SKAction {
        let colorAction = SKAction.colorize(
            with: color, colorBlendFactor: Arkonia.mannaColorBlendMaximum,
            duration: timeRequiredForFullBloom
        )

        var group = [colorAction, fadeInAction]

        // Just for interesting nerdy visuals, scale the manna to the same
        // scale as its pollenator
        if let s = scaleFactor {
            let newScale = constrain(s / 75, lo: 0.7, hi: 7) * Arkonia.mannaScaleFactor / Arkonia.zoomFactor
            let scaleAction = SKAction.scale(to: newScale, duration: timeRequiredForFullBloom)
            group.append(scaleAction)
        }

        return SKAction.group(group)
    }

    static let firstFadeInAction = SKAction.fadeAlpha(
        to: 0.4, duration: 0.01
    )

    static let fadeInAction = SKAction.fadeAlpha(
        to: 0.4, duration: Arkonia.mannaFullGrowthDurationSeconds
    )

    var isPhotosynthesizing: Bool {
        sprite.colorBlendFactor > Arkonia.mannaColorBlendMinimum
    }

    func bloom(maturity: TimeInterval, color: SKColor, scaleFactor: CGFloat) {
        // Select for arkons that leave the manna to bloom more, in order to
        // get more nutrition. If they eat it too early, it will take longer to
        // rebloom to full nutritional value
        let recoveryRatio = maturity < 1 ? 1 - maturity : 0
        let timeRequiredForFullBloom = Arkonia.mannaFullGrowthDurationSeconds * (1 + recoveryRatio)

        let toRun = Manna.Sprite.bloomAction(timeRequiredForFullBloom, color, scaleFactor)

        MannaCannon.mannaPlaneQueue.async { MannaCannon.shared!.cPhotosynthesizingManna += 1 }

        sprite.run(toRun)
    }

    func firstBloom(at cell: GridCell) {
        prepForFirstPlanting(at: cell)

        MannaCannon.mannaPlaneQueue.async { MannaCannon.shared!.cPhotosynthesizingManna += 1 }

        // Ok to let this run independently of the caller's thread, we don't
        // need anything from it, so there's no need to wait for completion
        sprite.run(Manna.Sprite.firstBloomAction)
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
        self.gridCell = cell
        sprite.setScale(Arkonia.mannaScaleFactor / Arkonia.zoomFactor)
        sprite.position = cell?.randomScenePosition ?? cell!.scenePosition
        sprite.zPosition = 0
    }

    func reset() {
        sprite.removeAllActions()
        sprite.alpha = 0
        sprite.color = .black
        sprite.colorBlendFactor = Arkonia.mannaColorBlendMinimum
    }
}
