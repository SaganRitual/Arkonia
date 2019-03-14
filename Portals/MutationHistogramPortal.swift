import Foundation
import SpriteKit

struct MutationHistogramPortal {
    typealias HistogramGetter = (Int) -> Double

    var columns = [Column]()
    let parentSprite: SKSpriteNode
    let sprites: [SKSpriteNode]

    init(_ statsPortal: SKSpriteNode) {
        guard let histogramPortal =
            statsPortal.childNode(withName: "mutationTypeCountsHistogram") as? SKSpriteNode else {
            preconditionFailure()
        }

        var sprites = [SKSpriteNode]()
        histogramPortal.enumerateChildNodes(withName: "mutationTypesHistogramBars") {
            node, _ in if let n = node as? SKSpriteNode { sprites.append(n) }
        }

        sprites.enumerated().forEach { t in let (ss, sprite) = t
            sprite.color = ColorGradient.makeColor(ss, sprites.count)
        }

        self.parentSprite = statsPortal
        self.sprites = sprites
    }
}

extension MutationHistogramPortal {
    static func postInit(_ histogramPortal: MutationHistogramPortal) {
        let updateAction = SKAction.run {
            guard let maxHeight: Double = histogramPortal.columns.max(by: { lhs, rhs in
                lhs.value < rhs.value
        })?.value else { return }

            histogramPortal.columns.forEach { column in
                column.sprite.yScale = CGFloat(column.value / maxHeight)
            }
        }

        MutationHistogramPortal.addActionsToSprite(
            histogramPortal.parentSprite, updateAction: updateAction
        )
    }

    static func addActionsToSprite(_ sprite: SKSpriteNode, updateAction: SKAction) {
        let delayAction = SKAction.wait(forDuration: 1.0)

        let updateOncePerSecond = SKAction.sequence([delayAction, updateAction])
        let updateForever = SKAction.repeatForever(updateOncePerSecond)
        sprite.run(updateForever)
    }

    mutating func attachToColumns(getter: @escaping HistogramGetter) {
        columns = sprites.enumerated().map { t in let (columnNumber, sprite) = t
            return Column(columnNumber: columnNumber, sprite: sprite, getter: getter)
        }

        columns.forEach { $0.sprite.yScale = 0.01 }
    }
}

extension MutationHistogramPortal {
    class Column {
        let columnNumber: Int
        let getter: HistogramGetter
        let sprite: SKSpriteNode
        var value = 0.0

        init(columnNumber: Int, sprite: SKSpriteNode, getter: @escaping HistogramGetter) {
            self.columnNumber = columnNumber
            self.getter = getter
            self.sprite = sprite
            sprite.anchorPoint = CGPoint(x: 0.5, y: 0)

            let updateAction = SKAction.run { [weak self] in self?.value = getter(columnNumber) }
            MutationHistogramPortal.addActionsToSprite(sprite, updateAction: updateAction)

            let delayAction = SKAction.wait(forDuration: 1.0)
            let updateOncePerSecond = SKAction.sequence([delayAction, updateAction])
            let updateForever = SKAction.repeatForever(updateOncePerSecond)
            sprite.run(updateForever)
        }
    }
}
