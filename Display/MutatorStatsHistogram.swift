import Foundation
import SpriteKit

protocol DStatsHistogramProtocol {
    associatedtype StatType: CaseIterable, Hashable

    static var columnColors: [Int] { get }

    var columns: [StatType: DStatsHistogramColumn] { get set }

    init(parentPortal: SKSpriteNode, cColumns: Int)

    func accumulate(functionID: StatType, zoomOut: Bool)
}

extension DStatsHistogramProtocol {

}

public enum IntlyHack: Int, CaseIterable, Hashable {
    case zero = 2, one, two, three, four, five, six, seven, eight, nine
}

class DStatsHistogramColumn {
    let columnNumber: Int
    var counter = 0
    let sprite: SKSpriteNode

    init(columnNumber: Int, sprite: SKSpriteNode) {
        self.columnNumber = columnNumber
        self.sprite = sprite
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0)
    }
}

class DStatsHistogram {
    static let columnColors = [
        0xC64E6C, 0xC54580, 0xC43D97, 0xC336B1, 0xB72EC3,
        0x9626C2, 0x721EC1, 0x4A16C1, 0x200FC0, 0x071BBF, 0x003CBF
    ]

    let cBuckets = 10
//    let portal: SKSpriteNode
    static let baseXScale: CGFloat = 2.5
    static let baseYScale: CGFloat = 1.25

    init(parentPortal: SKSpriteNode, histogramBackground: SKSpriteNode) {
        parentPortal.addChild(histogramBackground)
    }
}

final class SegmentMutationStatsHistogram: DStatsHistogram, DStatsHistogramProtocol {
    typealias StatType = IntlyHack

    var columns = [StatType: DStatsHistogramColumn]()
    let scale = CGSize(
        width: DStatsHistogram.baseXScale / (CGFloat(StatType.allCases.count) + 1),
        height: DStatsHistogram.baseYScale
    )

    init(parentPortal: SKSpriteNode, cColumns: Int) {
        let myBackground =
            DStatsHistogram.makeBackground(containerPortal: parentPortal, scale: scale)

        self.columns = StatType.allCases.enumerated().reduce([:]) {
            (dictionary, element) -> [StatType: DStatsHistogramColumn] in

            let (columnNumber, functionID) = element

            let s = SKSpriteNode(texture: ArkonCentralLight.sceneBackgroundTexture)
            s.color = MutatorStatsHistogram.makeColor(column: columnNumber)
            s.colorBlendFactor = 1.0

            let barWidth = parentPortal.frame.size.width / CGFloat(cColumns + 1)
            s.position = CGPoint(x: 4 * (barWidth * CGFloat(columnNumber)), y: 0)
            s.position.x -= parentPortal.frame.size.width + (barWidth * 8)
            s.position.y -= parentPortal.frame.size.height / 3
            myBackground.addChild(s)

            var d = dictionary
            d[functionID] = DStatsHistogramColumn(columnNumber: columnNumber, sprite: s)

            return d
        }

        super.init(parentPortal: parentPortal, histogramBackground: myBackground)
    }

    func accumulate(functionID: StatType, zoomOut: Bool = false) {
        columns[functionID]!.counter += 1

        if zoomOut {
            columns[.zero]!.counter = columns.map { $0.value.counter }.reduce(0, +)
            for column in columns where column.value.columnNumber > 0 {
                column.value.counter = 0
            }
        }

        updateDisplay()
    }
}

final class MutatorStatsHistogram: DStatsHistogram, DStatsHistogramProtocol {
    typealias StatType = Mutator.MutationType

    var columns = [StatType: DStatsHistogramColumn]()

    let scale = CGSize(
        width: DStatsHistogram.baseXScale / (CGFloat(StatType.allCases.count) + 1),
        height: DStatsHistogram.baseYScale
    )

    init(parentPortal: SKSpriteNode, cColumns: Int) {
        let myBackground =
            DStatsHistogram.makeBackground(containerPortal: parentPortal, scale: scale)

        self.columns = StatType.allCases.enumerated().reduce([:]) {
            (dictionary, element) -> [StatType: DStatsHistogramColumn] in
            let (columnNumber, functionID) = element

            let s = SKSpriteNode(texture: ArkonCentralLight.sceneBackgroundTexture)
            s.color = MutatorStatsHistogram.makeColor(column: columnNumber)
            s.colorBlendFactor = 1.0

            let barWidth = parentPortal.frame.size.width / CGFloat(cColumns + 1)
            s.position = CGPoint(x: 4 * (barWidth * CGFloat(columnNumber)), y: 0)
            s.position.x -= parentPortal.frame.size.width + (barWidth * 8)
            s.position.y -= parentPortal.frame.size.height / 3
            myBackground.addChild(s)

            var d = dictionary
            d[functionID] = DStatsHistogramColumn(columnNumber: columnNumber, sprite: s)

            return d
        }

        super.init(parentPortal: parentPortal, histogramBackground: myBackground)
    }

    func accumulate(functionID: StatType, zoomOut: Bool) {
        columns[functionID]!.counter += 1
        updateDisplay()
    }
}

extension DStatsHistogramProtocol {

    func updateDisplay() {
        let heightOfTallest = columns.max { $0.value.counter < $1.value.counter }!.value.counter
        let scaleFactor = 1.0 / CGFloat(heightOfTallest)
        for column in columns {
            column.value.sprite.yScale =
                (scaleFactor * DStatsHistogram.baseYScale) * CGFloat(column.value.counter)
        }
    }
}

extension DStatsHistogram {
    static func makeBackground(containerPortal: SKSpriteNode, scale: CGSize) -> SKSpriteNode {
        let background = SKSpriteNode(texture: ArkonCentralLight.sceneBackgroundTexture)
        background.size = containerPortal.frame.size
        background.color = .black
        background.colorBlendFactor = 1.0
        background.xScale = scale.width
        background.yScale = scale.height

        return background
    }
}

extension DStatsHistogramProtocol {
    static func makeColor(column: Int) -> NSColor {
        let index = columnColors.index(columnColors.startIndex, offsetBy: column)
        return ArkonCentralLight.makeColor(hexRGB: columnColors[index])
    }
}
