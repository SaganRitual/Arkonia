import Foundation
import SpriteKit

//swiftlint:disable large_tuple
protocol BarChartSource {
    func getCountsCompressed() -> (Double, [Int], Int)
    func getCountsTruncated() -> ([Int], Int)
}
//swiftlint:enable large_tuple

class BarChart {
    static let barNameTemplate = "bar_chart_bar_"

    var barChartLabel: SKLabelNode
    var barChartTopOfRange: SKLabelNode
    private let bars: [SKSpriteNode]
    private let chartNode: SKSpriteNode
    private let namePrefix: String

    init(chartNode: SKSpriteNode, namePrefix: String, datasource: BarChartSource) {
        self.namePrefix = namePrefix

        bars = BarChart.setupBarSprites(chartNode, namePrefix: namePrefix)

        barChartLabel = BarChart.setChartLabel(
            "Bell Curve", chartNode: chartNode, namePrefix: namePrefix
        )

        (barChartLogBase, barChartTopOfRange) =
            BarChart.initDynamicLabels(chartNode: chartNode, namePrefix: namePrefix)

        self.chartNode = chartNode
        self.datasource = datasource

        self.start()
    }

    func start() {
//        let updateAction = SKAction.run { [weak self] in self?.update() }
//        let delayAction = SKAction.wait(forDuration: 1.0)
//        let updateOncePerSecond = SKAction.sequence([delayAction, updateAction])
//        let updateForever = SKAction.repeatForever(updateOncePerSecond)

//        let scale = SKAction.scaleY(to: 0.01, duration: 0.5)

//        let toChildren: [SKAction] = (0..<10).map { barf in
//            SKAction.run(scale, onChildWithName: namePrefix + "bar_chart_bar_0\($0)")
//        }

//        let dazzle = SKAction.group(toChildren)
//        let launch = SKAction.sequence([dazzle, updateForever])

//        chartNode.run(launch)
//        chartNode.run(updateForever)
    }

    func update() {
//        let (baseValue, counts, topOfRange) = datasource.getCountsCompressed()
////        let (counts, topOfRange) = datasource.getCountsTruncated()
//        guard let maxHeight = counts.max() else { return }
//
//        let resize: [SKAction] = zip(counts, bars).map { (arg) in let (count, bar) = arg
//            let yScale = max(0.1, CGFloat(count) / CGFloat(maxHeight))
//            let scaleAction = SKAction.scaleY(to: yScale, duration: 0.25)
//            let childAction = SKAction.run(scaleAction, onChildWithName: bar.name!)
//            return childAction
//        }
//
//        let group = SKAction.group(resize)
//        chartNode.run(group)
//
//        barChartLogBase.text = String(format: "base %2.1f", baseValue)
//        barChartTopOfRange.text = String(format: "range %d", topOfRange)
//
//        barChartLogBase.alpha = 1.0
//        barChartTopOfRange.alpha = 1.0
    }
}

// MARK: Setup chart components

extension BarChart {

    static func initDynamicLabels(chartNode: SKSpriteNode, namePrefix: String)
        -> (SKLabelNode, SKLabelNode)
    {
        let topOfRangeLabel = namePrefix + "bar_chart_top_of_range"
        let logBaseLabel = namePrefix + "bar_chart_log_base"

        guard let topOfRange = chartNode.childNode(withName: topOfRangeLabel) as? SKLabelNode,
            let logBase = chartNode.childNode(withName: logBaseLabel) as? SKLabelNode
            else { preconditionFailure() }

        topOfRange.alpha = 0
        logBase.alpha = 0

        return (topOfRange, logBase)
    }

    static func setChartLabel(_ text: String, chartNode: SKSpriteNode, namePrefix: String)
        -> SKLabelNode
    {
        let barChartLabel = namePrefix + "bar_chart_label"
        guard let label = chartNode.childNode(withName: barChartLabel) as? SKLabelNode
            else { preconditionFailure() }

        label.text = text
        return label
    }

    static func setupBarSprites(_ chartNode: SKSpriteNode, namePrefix: String)
        -> [SKSpriteNode]
    {
        var b = [SKSpriteNode]()

        b = (0..<10).map {
            let name = String(format: namePrefix + "\(barNameTemplate)%02d", $0)
            guard let bar = chartNode.childNode(withName: name) as? SKSpriteNode
                else { preconditionFailure() }

            return bar
        }

        return b
    }

}
