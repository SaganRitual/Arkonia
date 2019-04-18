import SpriteKit

class PortalServer {
    static var shared: PortalServer!

    var arkonsPortal : SKSpriteNode
    var clockPortal:         ClockPortal
    var duggarStatsPortal:   DuggarStatsPortal
    var generalStatsPortals: GeneralStats
    var geneStatsPortal:     GeneStatsPortal
    var healthStatsPortal:   AgeStatsPortal
    var netPortal:           SKSpriteNode
    var popStatsPortal:      PopStatsPortal
    var statusCache =        [Arkon.Status]()
    var topLevelStatsPortal: SKSpriteNode

    private var portalNumber = 0

    init(scene: SKScene) {
        self.netPortal = PortalServer.initNetPortal(scene)

        let parentStatsPortal = PortalServer.initStatsPortal(scene)
        self.topLevelStatsPortal = parentStatsPortal
        self.clockPortal = ClockPortal(parentStatsPortal)

        let generalStatsPortals = GeneralStats(parentStatsPortal)
        self.geneStatsPortal = GeneStatsPortal(generalStatsPortals)

        self.healthStatsPortal = AgeStatsPortal(generalStatsPortals)
        self.popStatsPortal = PopStatsPortal(generalStatsPortals)
        self.duggarStatsPortal = DuggarStatsPortal(generalStatsPortals)

        self.generalStatsPortals = generalStatsPortals

        self.arkonsPortal = PortalServer.initArkonsPortal(scene)

        PortalServer.shared = self
    }
}

protocol AccessorProtocol {
    var displayItem: PortalServer.StatsDisplayItem { get set }
}

extension PortalServer {
    enum StatsDisplayItem { case int(Int), double(Double) }

    struct Accessor: AccessorProtocol {
        var displayItem: StatsDisplayItem

        init(_ displayItem: StatsDisplayItem) {
            self.displayItem = displayItem
        }

        mutating func update(_ newValue: StatsDisplayItem) {
            self.displayItem = newValue
        }
    }
}

extension PortalServer {

    static func initArkonsPortal(_ scene: SKNode) -> SKSpriteNode {
        guard let arkonsPortal = scene.childNode(withName: "arkonsPortal") as? SKSpriteNode
            else { preconditionFailure() }

        arkonsPortal.speed = 1
        arkonsPortal.color = .black
        arkonsPortal.colorBlendFactor = 1
        arkonsPortal.size.width  *= 1.00 * 0.99
        arkonsPortal.size.height *= 0.75 * 0.99
        arkonsPortal.position = CGPoint.zero

        let cropper = SKCropNode()

        cropper.maskNode = SKSpriteNode(color: .yellow, size: arkonsPortal.size)
        cropper.position = CGPoint(x: -scene.frame.size.width / 4, y: 0)
        cropper.zPosition = ArkonCentralLight.vArkonZPosition - 0.01

        scene.addChild(cropper)
        arkonsPortal.removeFromParent()
        cropper.addChild(arkonsPortal)

//        let delay = SKAction.wait(forDuration: TimeInterval(1.0 * arkonsPortal.speed))
//        let statusCacheUpdater = SKAction.run {
//            if World.shared.populationChanged {
//                PortalServer.shared.statusCache =
//                PortalServer.shared.arkonsPortal.children.compactMap { node in
//                    guard let sprite = node as? Karamba else { return nil }
//                    guard let arkon = sprite.arkon else { return nil }
//                    return arkon.status
//                }
//            }
//
//            World.shared.populationChanged = false
//        }

//        let updateActionOncePerSecond = SKAction.sequence([delay, statusCacheUpdater])
//        let runForever = SKAction.repeatForever(updateActionOncePerSecond)

//        arkonsPortal.run(runForever)
        return arkonsPortal
    }

    static func initNetPortal(_ scene: SKNode) -> SKSpriteNode {
        guard let netPortal = scene.childNode(withName: "netPortal") as? SKSpriteNode
            else { preconditionFailure() }

        netPortal.setScale(0.5)
        netPortal.size.width *= 2 * 0.99
        netPortal.size.height *= 2 * 0.75 * 0.99
        netPortal.position.y = scene.frame.size.height / 4
        netPortal.position.x = (scene.frame.size.width / 4)

        return netPortal
    }

    static func initStatsPortal(_ scene: SKNode) -> SKSpriteNode {
        guard let statsPortal = scene.childNode(withName: "statsPortal") as? SKSpriteNode
            else { preconditionFailure() }

        statsPortal.yScale = 0.75 * 0.99
        statsPortal.position.y = -scene.frame.size.height / 4

        // Hack because I'm sick of using the scene editor
        statsPortal.position.x -= 2.0 * 0.75 * 0.99

        return statsPortal
    }

}
