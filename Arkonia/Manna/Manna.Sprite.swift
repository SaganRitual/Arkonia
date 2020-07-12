import SpriteKit

extension Manna.Sprite {
    static let firstBloomAction = SKAction.group([firstFadeInAction, firstColorAction])

    private static let firstColorAction = SKAction.colorize(
        with: .darkGray, colorBlendFactor: Arkonia.mannaColorBlendMaximum,
        duration: 0.01
    )

    private static func bloomAction(
        _ timeRequiredForFullBloom: TimeInterval,
        _ timingFunction: @escaping (Float) -> Float,
        _ color: SKColor,
        _ scaleFactor: CGFloat? = nil
    ) -> SKAction {
        let colorAction = SKAction.colorize(
            with: color, colorBlendFactor: Arkonia.mannaColorBlendMaximum,
            duration: timeRequiredForFullBloom
        )

        let fadeInAction = SKAction.fadeAlpha(
            to: 0.4, duration: timeRequiredForFullBloom
        )

        colorAction.timingMode = .easeIn
        fadeInAction.timingMode = .easeIn

        colorAction.timingFunction = timingFunction
        fadeInAction.timingFunction = timingFunction

        var group = [colorAction, fadeInAction]

        // Just for interesting nerdy visuals, scale the manna to the same
        // scale as its pollenator
        if let s = scaleFactor {
            let newScale = constrain(s / 75, lo: 1.25, hi: 2) * Arkonia.mannaScaleFactor / Arkonia.zoomFactor
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

    func bloom(_ timeRequiredForFullBloom: Double, color: SKColor, scaleFactor: CGFloat) {
        let toRun = Manna.Sprite.bloomAction(
            timeRequiredForFullBloom, bloomTimingFunction, color, scaleFactor
        )

        MannaCannon.mannaPlaneQueue.async {
            MannaCannon.shared!.cPhotosynthesizingManna += 1
        }

        sprite.run(toRun)
    }

    func bloomTimingFunction(_ inputTime: Float) -> Float {
        // See how we feel about an 80/20 kind of thing, where we have to be 80%
        // mature to reach 20% of our nutritional value, then there is a big burst
        // to full nutrition during the last 20% of maturation
        // The 80/20 rule is more generally n / (1 - n)
        // SpriteKit gives us 0.0..<1.0

        let eighty: Float = 0.8
        let twenty: Float = 1.0 - eighty

        return inputTime < eighty ? twenty * inputTime : inputTime
    }

    func firstBloom(at absoluteGridIndex: Int) {
        prepForFirstPlanting(at: absoluteGridIndex)

        MannaCannon.mannaPlaneQueue.async {
            MannaCannon.shared!.cPhotosynthesizingManna += 1
        }

        // Ok to let this run independently of the caller's thread, we don't
        // need anything from it, so there's no need to wait for completion
        sprite.run(Manna.Sprite.firstBloomAction)
    }

    func getMaturityLevel() -> CGFloat {
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

    private func prepForFirstPlanting(at cellAbsoluteIndex: Int) {
        sprite.setScale(Arkonia.mannaScaleFactor / Arkonia.zoomFactor)
        sprite.position = Grid.cellAt(cellAbsoluteIndex).properties.scenePosition
        sprite.zPosition = 0
    }

    func reset() {
        sprite.removeAllActions()
        sprite.alpha = 0
        sprite.color = .black
        sprite.colorBlendFactor = Arkonia.mannaColorBlendMinimum
    }
}
