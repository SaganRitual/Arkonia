import Foundation
import SpriteKit

class AgeStatsPortal {
    static var shared: AgeStatsPortal!

    private var highWaterMark = 0.0

    func demoteFromDuggarest(_ arkon: Arkon, _ shrink: Bool) {
        precondition(arkon.status.isDuggarest == true)
        arkon.status.isDuggarest = false
        let color: NSColor = arkon.status.isOldest ? .orange : .magenta

        arkon.sprite.color = color
        if shrink { arkon.sprite.size /= 2.0 }
//        let colorAction =
//            SKAction.colorize(with: color, colorBlendFactor: 1, duration: 0.25)
//
//        var actions = [colorAction]
//
//        if shrink { print("1shrink", arkon.fishNumber); actions.append(SKAction.scale(by: 0.5, duration: 0.25)) }
//
//        let light = SKAction.group(actions)
//        let spriteName = arkon.sprite.name!
//        let dark = SKAction.run {
//            let node = PortalServer.shared.arkonsPortal.childNode(withName: spriteName)
//            guard let sprite = node as? SKSpriteNode else { return }
//            guard let arkon: Arkon = sprite.getUserData(SKSpriteNode.UserDataKey.arkon) else { return }
//        }

//        let demote = SKAction.sequence([light])
//        let remote = SKAction.run(demote, onChildWithName: spriteName)
//
//        PortalServer.shared.arkonsPortal.run(remote)
    }

    func promoteToDuggarest(_ arkon: Arkon, _ grow: Bool) {
        precondition(arkon.status.isDuggarest == false)
        arkon.status.isDuggarest = true
        arkon.sprite.color = .purple
        if grow { arkon.sprite.size *= 2.0 }

//        let colorAction =
//            SKAction.colorize(with: .purple, colorBlendFactor: 1, duration: 0.25)
//
//        var actions = [colorAction]
//        if grow { print("1 scale up", arkon.fishNumber); actions.append(SKAction.scale(by: 2, duration: 0.25)) }
//
//        let light = SKAction.group(actions)
//        let spriteName = arkon.sprite.name!
//        let dark = SKAction.run {
//            let node = PortalServer.shared.arkonsPortal.childNode(withName: spriteName)
//            guard let sprite = node as? SKSpriteNode else { return }
//            guard let arkon: Arkon = sprite.getUserData(SKSpriteNode.UserDataKey.arkon) else { return }
//        }

//        let promote = SKAction.sequence([light])
//        let remote = SKAction.run(promote, onChildWithName: spriteName)
//        PortalServer.shared.arkonsPortal.run(remote)
    }

    func promoteToOldest(_ arkon: Arkon, _ grow: Bool) {
        precondition(arkon.status.isOldest == false)
        arkon.status.isOldest = true
        arkon.sprite.color = .orange
//        let colorAction =
//            SKAction.colorize(with: .orange, colorBlendFactor: 1, duration: 0.25)

//        var actions = [colorAction]
//        if grow { print("2 scale up", arkon.fishNumber); actions.append(SKAction.scale(by: 2, duration: 0.25)) }

        if grow { arkon.sprite.size *= 2.0 }
//        let light = SKAction.group(actions)
//        let spriteName = arkon.sprite.name!
//        let dark = SKAction.run {
//            let node = PortalServer.shared.arkonsPortal.childNode(withName: spriteName)
//            guard let sprite = node as? SKSpriteNode else { return }
//            guard let arkon: Arkon = sprite.getUserData(SKSpriteNode.UserDataKey.arkon) else { return }
//        }

//        let promote = SKAction.sequence([light])
//        let remote = SKAction.run(promote, onChildWithName: spriteName)
//        PortalServer.shared.arkonsPortal.run(remote)
    }

    init(_ generalStatsPortals: GeneralStats) {
        AgeStatsPortal.shared = self

        generalStatsPortals.setUpdater(subportal: 2, field: 0) { [weak self] in
            guard let myself = self else { preconditionFailure() }

            let p = World.shared.population.getArkonsByAge().reversed()
            if p.count < 2 { return "" }

            let contenderForOldest_ = p.dropFirst()
            let contenderForOldest = contenderForOldest_[contenderForOldest_.startIndex]
            let isShowingNet = contenderForOldest.status.isOldest
            contenderForOldest.status.isOldest = true

            if !isShowingNet {
                Display.shared.display(
                    contenderForOldest.signalDriver.kNet, portal: PortalServer.shared.netPortal
                )
            }

            if contenderForOldest.status.age > myself.highWaterMark {
                myself.highWaterMark = contenderForOldest.status.age
            }

            return String(format: "Oldest: %.2f", contenderForOldest.status.age)
        }

        generalStatsPortals.setUpdater(subportal: 2, field: 1) { [weak self] in
            guard let myself = self else { preconditionFailure() }
            return String(format: "Record: %.2f", myself.highWaterMark)
        }

        generalStatsPortals.setUpdater(subportal: 2, field: 2) {
            let p = World.shared.population.getArkons()
            let average = p.isEmpty ? 0 :
                p.reduce(0, { $0 + $1.status.age }) / TimeInterval(p.count)

            return String(format: "Average: %.2f", average)
        }

        generalStatsPortals.setUpdater(subportal: 2, field: 3) {
            let p = World.shared.population.getArkons()
            let whichArkon = p.count / 2
            let median = p.isEmpty ? 0 : p[whichArkon].status.age
            return String(format: "Median: %.2f", median)
        }
   }
}
