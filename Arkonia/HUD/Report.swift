import Foundation
import SpriteKit

class ReportFactory {
    let hud: HUD

    init(hud: HUD) { self.hud = hud }

    func newReport() -> Report { return (hud.prototypes.report.copy() as? Report)! }
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
        // Note: start at child #1, zero is the title, because laziness
        let toChildren: [SKAction] = (1...3).map {
            let r = reportoid($0)
            let scaleDown = SKAction.scaleY(to: 0.01, duration: Arkonia.random(in: 0.5..<1.5))
            let scaleUp = SKAction.scaleY(to: 1, duration: Arkonia.random(in: 0.5..<1.5))
            let sequence = SKAction.sequence([scaleDown, scaleUp])
            let c1 = SKAction.run(sequence, onChildWithName: r.data.name!)
            let c2 = SKAction.run(sequence, onChildWithName: r.label.name!)
            return SKAction.group([c1, c2])
       }

        let dazzle = SKAction.group(toChildren)
        run(dazzle)
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
