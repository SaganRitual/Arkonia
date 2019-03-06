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
        guard let sprite = node as? SKSpriteNode else { return 0 }
        return getAge(sprite)
    }

    private func getAge(_ sprite: SKSpriteNode) -> TimeInterval {
        guard let arkon = sprite.arkon else { preconditionFailure() }
        return (arkon.birthday > 0) ? arkon.myAge : 0
    }

    private func getKNet(_ arkon: Arkon) -> KNet? {
        return arkon.signalDriver.kNet
    }

    private func getOldestLivingArkon() -> Arkon? {
        guard let sprite = getSpriteOfOldestLivingArkon() else { return nil }
        guard let arkon = sprite.arkon else { return nil }
        guard arkon.birthday > 0 else { return nil }
        return arkon
    }

    private func getSpriteOfOldestLivingArkon() -> SKSpriteNode? {
        func f(_ node: SKNode) -> Bool { return node.name?.hasPrefix("Arkon") ?? false }
        func m(_ lhs: SKNode, _ rhs: SKNode) -> Bool { return getAge(lhs) < getAge(rhs) }

        guard let oldest = arkonsPortal.children.filter(f).max(by: m) as? SKSpriteNode
            else { return nil }

        return oldest
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
