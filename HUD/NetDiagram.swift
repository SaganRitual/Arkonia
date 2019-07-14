import Foundation
import SpriteKit

class NetDiagramFactory {
    private let prototype: NetDiagram

    init(hud: HUD) {
        guard let p = hud.getNetPortal() as? NetDiagram else { preconditionFailure() }
        prototype = p
        hud.releasePrototype(prototype)
    }

    func newDiagram() -> NetDiagram {
        let nd = hardBind(prototype.copy() as? NetDiagram)
        nd.netPortal = prototype
        return nd
    }
}

final class NetDiagram: SKSpriteNode {
    var netPortal: NetDiagram!

    func update() {
//        guard let scene = Display.shared?.scene else { return }
//        guard let arkonsPortal = scene.childNode(withName: "arkons_portal") as? SKSpriteNode
//            else { return }

//        let liveArkons: [Karamba] = arkonsPortal.children.compactMap { $0 as? Karamba }
//        if liveArkons.isEmpty { return }

//        let sorted = liveArkons.sorted { $0.age < $1.age }
//        guard let oldestArkon = sorted.last else { return }

//        guard let netPortal = scene.childNode(withName: "net_portal") as? SKSpriteNode
//            else { return }

//        DNet(oldestArkon.signalDriver.kNet).display(via: netPortal)
    }
}
