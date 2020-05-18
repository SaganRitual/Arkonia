import Foundation
import SpriteKit

class BarChartFactory {
    let hud: HUD

    init(hud: HUD) { self.hud = hud }

    func newChart() -> BarChart { (hud.prototypes.barchart.copy() as? BarChart)! }
}

final class BarChart: SKSpriteNode {
    var buckets = [Int](repeating: 0, count: 10)

    func bar(_ whichBar: Int) -> SKSpriteNode {
        return children.compactMap {
            if !($0.name ?? "").starts(with: "bar_chart_bar_") { return nil }
            return $0 as? SKSpriteNode
        }.sorted { $0.name ?? "" < $1.name ?? "" }[whichBar]
    }

    func reset() { SceneDispatch.shared.schedule { (0..<self.buckets.count).forEach { self.buckets[$0] = 0 } } }

    func start() {
        let updateAction = SKAction.run { [weak self] in self?.update() }
        let delayAction = SKAction.wait(forDuration: 0.5)
        let updateOncePerSecond = SKAction.sequence([delayAction, updateAction])
        let updateForever = SKAction.repeatForever(updateOncePerSecond)

        let toChildren: [SKAction] = (0..<10).map {
            let scale = SKAction.scaleY(to: 0.01, duration: TimeInterval.random(in: 0.5..<1.5))

            return SKAction.run(scale, onChildWithName: bar($0).name!)
        }

        let dazzle = SKAction.group(toChildren)
        let fly = SKAction.sequence([dazzle, updateForever])

        run(fly)
    }

    func update() {
        let unit = CGFloat(buckets.max()!)
        guard unit > 0 else { return }

        (0..<10).forEach { bucketSS in
            let scaleValue = 0.95 * CGFloat(buckets[bucketSS]) / unit
            let duration = TimeInterval.random(in: 0..<0.41)

            Debug.log(level: 161) { "bucketSS = \(bucketSS), unit = \(unit), scaleValue = \(scaleValue)" }

            let scaleAction = SKAction.scaleY(to: scaleValue, duration: duration)
            let toChild = SKAction.run(scaleAction, onChildWithName: bar(bucketSS).name!)
            run(toChild, completion: { [weak self] in self?.buckets[bucketSS] = 0})
        }
    }
}

// MARK: Setup chart components

extension BarChart {

    func addSample(_ sample: CGFloat) {
        let scaledAndCentered = Int(abs(sample) * 100) / 10
        let whichBar = (scaledAndCentered < 10) ? scaledAndCentered : (10 - 1)
        SceneDispatch.shared.schedule { self.buckets[whichBar] += 1 }
    }

    func addSample(_ sample: Int) {
        // If we get a value too big, count it in the rightmost bar
        let whichBar = min(sample / 50, buckets.count - 1)
        SceneDispatch.shared.schedule { self.buckets[whichBar] += 1 }

        Debug.log(level: 161) { "addSample(\(sample)) -> bucket[\(whichBar)] = \(buckets[whichBar])" }
    }

    func subtractSample(_ sample: Int) {
        // If we get a value too big, count it in the rightmost bar
        let whichBar = min(sample / 50, buckets.count - 1)
        SceneDispatch.shared.schedule { self.buckets[whichBar] -= 1 }

        Debug.log(level: 161) { "subtractSample(\(sample)) -> bucket[\(whichBar)] = \(buckets[whichBar])" }
    }

    func setChartLabel(_ text: String) {
        let barChartLabel = "barchart_title_understudy"
        let node = childNode(withName: barChartLabel)
        let label = (node as? SKLabelNode)!
        label.text = text
        label.fontColor = .yellow
        label.color = .blue
        label.zPosition = 0
        label.alpha = 1.0
    }

}
