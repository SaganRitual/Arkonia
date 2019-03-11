import Foundation
import SpriteKit

class DStatsHistogram {

    static let columnColors = [
        0xC64E6C, 0xC54580, 0xC43D97, 0xC336B1, 0xB72EC3,
        0x9626C2, 0x721EC1, 0x4A16C1, 0x200FC0, 0x071BBF, 0x003CBF
    ]

    var columns = [Mutator.MutationType: DStatsHistogram.Column]()
    let cBuckets = 10
    let portal: SKSpriteNode
    let baseXScale: CGFloat = 2.5
    let baseYScale: CGFloat = 1.25

    init(parentPortal: SKSpriteNode, cColumns: Int) {
        let background =
            DStatsHistogram.makeBackground(
                containerPortal: parentPortal,
                scale: CGSize(width: baseXScale, height: baseYScale
            )
        )

        self.columns = Mutator.MutationType.allCases.enumerated().reduce([:]) {
            (dictionary, element) -> [Mutator.MutationType: DStatsHistogram.Column] in
            let (columnNumber, functionID) = element

            let s = SKSpriteNode(texture: ArkonCentralLight.sceneBackgroundTexture)
            s.color = DStatsHistogram.makeColor(column: columnNumber)
            s.colorBlendFactor = 1.0

            let barWidth = parentPortal.frame.size.width / CGFloat(cColumns + 1)
            s.position = CGPoint(x: 4 * (barWidth * CGFloat(columnNumber)), y: 0)
            s.position.x -= parentPortal.frame.size.width + (barWidth * 8)
            s.position.y -= parentPortal.frame.size.height / 3
            background.addChild(s)

            var d = dictionary
            d[functionID] = Column(columnNumber: columnNumber, sprite: s)

            return d
        }

        self.portal = background
        parentPortal.addChild(portal)
    }

    func accumulate(functionID: Mutator.MutationType) {
        columns[functionID]!.counter += 1
//        print("\(functionID) = \(columns[functionID]!.counter)")
        updateDisplay()
    }

    func updateDisplay() {
        let heightOfTallest = columns.max { $0.value.counter < $1.value.counter }!.value.counter
        let scaleFactor = 1.0 / CGFloat(heightOfTallest)
        for column in columns {
            column.value.sprite.yScale = (scaleFactor * baseYScale) * CGFloat(column.value.counter)
        }
    }
}

extension DStatsHistogram {
    static func makeBackground(containerPortal: SKSpriteNode, scale: CGSize) -> SKSpriteNode {
        let background = SKSpriteNode(texture: ArkonCentralLight.sceneBackgroundTexture)
        background.size = containerPortal.frame.size
        background.color = .black
        background.colorBlendFactor = 1.0
        background.xScale = scale.width / (CGFloat(Mutator.MutationType.allCases.count) + 1)
        background.yScale = scale.height

        return background
    }

    class Column {
        let columnNumber: Int
        var counter = 0
        let sprite: SKSpriteNode

        init(columnNumber: Int, sprite: SKSpriteNode) {
            self.columnNumber = columnNumber
            self.sprite = sprite
            sprite.anchorPoint = CGPoint(x: 0.5, y: 0)
        }
    }
}

extension DStatsHistogram {
    static func makeColor(column: Int) -> NSColor {
        let index = columnColors.index(columnColors.startIndex, offsetBy: column)
        return ArkonCentralLight.makeColor(hexRGB: columnColors[index])
    }
}
