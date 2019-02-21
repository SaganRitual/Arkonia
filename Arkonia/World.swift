import Foundation
import SpriteKit

class World {
    var arkons = [Arkon]()
    var portal: SKNode

    enum LaunchStage { case unready, readyForInit, flying }
    var launchStage = LaunchStage.unready

    init() {
        launchStage = .readyForInit
        portal = ArkonCentralLight.display!.getPortal(quadrant: 1)
    }

    private func deadArkonCleanup() { arkons.removeAll { !$0.isAlive } }

    func update(_ currentTime: TimeInterval, for scene: SKScene) -> LaunchStage {
        switch launchStage {
        case .unready:
            break

        case .readyForInit:
            precondition(self.arkons.isEmpty)

            self.arkons = (0..<100).map { Arkon(fishNumber: $0, portal: self.portal) }
            self.arkons.forEach { $0.comeToLife() }
            self.launchStage = .flying

        case .flying:
            deadArkonCleanup()
        }

        return self.launchStage
    }
}
