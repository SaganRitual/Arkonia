import Foundation
import SpriteKit

enum NetDiagramUpdate {
    static func getNetDiagramUpdater(_ netDiagram: NetDiagram) -> SKAction {
        let updateAction = SKAction.run {
            guard let scene = Display.shared?.scene else { return }
            guard let arkonsPortal = scene.childNode(withName: "arkons_portal") as? SKSpriteNode
                else { return }

            let liveArkons: [Karamba] = arkonsPortal.children.compactMap { $0 as? Karamba }
            if liveArkons.isEmpty { return }

            let sorted = liveArkons.sorted { $0.age < $1.age }
            guard let oldestArkon = sorted.last else { return }

            guard let netPortal = scene.childNode(withName: "net_portal") as? SKSpriteNode
                else { return }

            DNet(oldestArkon.signalDriver.kNet).display(via: netPortal)
        }

        return updateAction
    }
}
