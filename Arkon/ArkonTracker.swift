import Foundation
import SpriteKit

struct ArkonTracker {
    private let arkonsPortal: SKSpriteNode
    private let netPortal: SKSpriteNode

    lazy var oldestLivingArkon: Arkon? = getOldestLivingArkon()

    init?(arkonsPortal: SKSpriteNode, netPortal: SKSpriteNode) {
        if arkonsPortal.children.isEmpty { return nil }

        self.arkonsPortal = arkonsPortal
        self.netPortal = netPortal
    }

    private func getAge(_ node: SKNode) -> TimeInterval {
        guard let arkon = getArkon(for: node) else { return 0 }
        return (arkon.birthday > 0) ? arkon.myAge : 0
    }

    private func getArkon(for node: SKNode) -> Arkon? {
        guard let sprite = node as? SKSpriteNode else { return nil }
        guard let userData = sprite.userData else { return nil }
        guard let arkonEntry = userData["Arkon"] else { return nil }
        return arkonEntry as? Arkon
    }

    private func getKNet(_ arkon: Arkon) -> KNet? {
        return arkon.signalDriver.kNet
    }

    private func getOldestLivingArkon() -> Arkon? {
        guard let sprite = getSpriteOfOldestLivingArkon() else { return nil }
        guard let arkon = getArkon(for: sprite) else { return nil }
        guard arkon.birthday > 0 else { return nil }
        return arkon
    }

    private func getSpriteOfOldestLivingArkon() -> SKNode? {
        return arkonsPortal.children.max { lhs, rhs in return getAge(lhs) < getAge(rhs) }
    }

    mutating func updateDebugPortal() {
        guard let arkon = oldestLivingArkon else { return }

        DebugPortal.shared.specimens[.currentOldest]?.value = Int(arkon.myAge)
        DebugPortal.shared.specimens[.healthOfOldest]?.value = Int(arkon.health)
        DebugPortal.shared.specimens[.oldestCOffspring]?.value = Int(arkon.cOffspring)
    }

    mutating func updateNetPortal() {
        guard let arkon = oldestLivingArkon else { return }

        // We already knew that I'm the oldest, so we've
        // already drawn my net.
        if arkon.isShowingNet { return }

        guard let kNet = getKNet(arkon) else { return }

        Display.shared.display(kNet, portal: netPortal)
        arkon.isShowingNet = true
    }
}
