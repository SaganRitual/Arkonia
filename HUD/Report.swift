import Foundation
import SpriteKit

class ReportFactory {
    private let prototype: Report

    init(hud: HUD, scene: MainScene) {
        prototype = hardBind(hud.getPrototype(.report) as? Report)
        hud.releasePrototype(prototype)
    }

    func newReport() -> Report { return hardBind(prototype.copy() as? Report) }
}

struct Reportoid {
    let data: SKLabelNode
    let label: SKLabelNode
    let ss: Int
}

final class Report: SKSpriteNode {
    func reportoid(_ ss: Int) -> Reportoid {
        return children.compactMap { child in
            if !(child.name ?? "").starts(with: "reportoid_") { return nil }

            let sss = String(format: "%02d", ss)

            guard let dataNode = childNode(withName: "reportoid_data_\(sss)") as? SKLabelNode
                else { return nil }

            guard let labelNode = childNode(withName: "reportoid_label_\(sss)") as? SKLabelNode
                else { return nil }

            return Reportoid(data: dataNode, label: labelNode, ss: ss)
        }.sorted { $0.ss < $1.ss }[ss]
    }

    func start() {
        let updateAction = SKAction.run { [weak self] in self?.update() }
        let delayAction = SKAction.wait(forDuration: 0.5)
        let updateOncePerSecond = SKAction.sequence([delayAction, updateAction])
        let updateForever = SKAction.repeatForever(updateOncePerSecond)

        // Note: start at child #1, zero is the title, because laziness
        let toChildren: [SKAction] = (1..<5).map {
            let r = reportoid($0)
            let scaleDown = SKAction.scaleY(to: 0.01, duration: TimeInterval.random(in: 0.5..<1.5))
            let scaleUp = SKAction.scaleY(to: 1, duration: TimeInterval.random(in: 0.5..<1.5))
            let sequence = SKAction.sequence([scaleDown, scaleUp])
            let c1 = SKAction.run(sequence, onChildWithName: r.data.name!)
            let c2 = SKAction.run(sequence, onChildWithName: r.label.name!)
            return SKAction.group([c1, c2])
       }

        let dazzle = SKAction.group(toChildren)
        let fly = SKAction.sequence([dazzle, updateForever])

        run(fly)
    }

    func update() {
//        let unit = CGFloat(hardBind(buckets.max()))
//        guard unit > 0 else { return }
//
//        (0..<10).forEach {
//            let scaleValue = 0.95 * CGFloat(buckets[$0]) / unit
//            let duration = TimeInterval.random(in: 0..<0.4)
//
//            let scaleAction = SKAction.scaleY(to: scaleValue, duration: duration)
//            let toChild = SKAction.run(scaleAction, onChildWithName: hardBind(bar($0).name))
//            run(toChild)
//        }
    }
}

// MARK: Setup chart components

extension Report {

    func setTitle(_ title: String) {
        let node = childNode(withName: "report_title") as? SKLabelNode
        node!.text = title
    }

    func setReportoid(_ ss: Int, label: String, data: String) {
        setReportoidLabel(ss, text: label)
        setReportoidData(ss, text: data)
    }

    func setReportoidData(_ ss: Int, text: String) {
        let nodeName = String(format: "reportoid_data_%02d", ss)
        let node = childNode(withName: nodeName) as? SKLabelNode
        node!.text = text
    }

    func setReportoidLabel(_ ss: Int, text: String) {
        let nodeName = String(format: "reportoid_label_%02d", ss)
        let node = childNode(withName: nodeName) as? SKLabelNode
        node!.text = text
    }

}
