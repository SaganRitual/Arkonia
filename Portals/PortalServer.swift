import SpriteKit

class PortalServer {
    static var shared: PortalServer!

    let arkonsPortal: SKSpriteNode
    let clockPortal: ClockPortal
    let generalStatsPortals: GeneralStats
    let geneStatsPortal: GeneStatsPortal
    let healthStatsPortal: HealthStatsPortal
    let netPortal: SKSpriteNode
    let popStatsPortal: PopStatsPortal
    let topLevelStatsPortal: SKSpriteNode

    private var portalNumber = 0

    init(scene: SKScene) {
        self.arkonsPortal = PortalServer.initArkonsPortal(scene)
        self.netPortal = PortalServer.initNetPortal(scene)

        let parentStatsPortal = PortalServer.initStatsPortal(scene)
        self.topLevelStatsPortal = parentStatsPortal
        self.clockPortal = ClockPortal(parentStatsPortal)

        let generalStatsPortals = GeneralStats(parentStatsPortal)
        self.geneStatsPortal = GeneStatsPortal(generalStatsPortals)

        self.healthStatsPortal = HealthStatsPortal(generalStatsPortals)
        self.popStatsPortal = PopStatsPortal(generalStatsPortals)

        self.generalStatsPortals = generalStatsPortals

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

        arkonsPortal.speed = 0.1
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

        return arkonsPortal
    }

    static func initNetPortal(_ scene: SKNode) -> SKSpriteNode {
        guard let netPortal = scene.childNode(withName: "netPortal") as? SKSpriteNode
            else { preconditionFailure() }

        netPortal.setScale(0.5)
        netPortal.size.width *= 2
        netPortal.size.height *= 2 * 0.75
        netPortal.position.y = scene.frame.size.height / 4
        netPortal.position.x = scene.frame.size.width / 4

        return netPortal
    }

    static func initStatsPortal(_ scene: SKNode) -> SKSpriteNode {
        guard let statsPortal = scene.childNode(withName: "statsPortal") as? SKSpriteNode
            else { preconditionFailure() }

        statsPortal.yScale = 0.75 * 0.98
//        statsPortal.color = .yellow
//        statsPortal.colorBlendFactor = 1.0
        statsPortal.position.y = -scene.frame.size.height / 4

        return statsPortal
    }

}

extension CGSize {
    func asPoint() -> CGPoint { return CGPoint(x: width, y: height) }

    static func * (_ lhs: CGSize, _ rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }

//    static func * (_ lhs: CGSize, _ rhs: (x: CGFloat, y: CGFloat)) -> CGSize {
//        return CGSize(width: lhs.width * rhs.x, height: lhs.height * rhs.y)
//    }

    static func * (_ lhs: CGSize, _ rhs: (x: Int, y: Int)) -> CGSize {
        return CGSize(width: lhs.width * CGFloat(rhs.x), height: lhs.height * CGFloat(rhs.y))
    }

    static func * (_ lhs: CGSize, _ rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
    }

    static func / (_ lhs: CGFloat, _ rhs: CGSize) -> CGSize {
        return CGSize(width: lhs / rhs.width, height: lhs / rhs.height)
    }

    static func / (_ lhs: CGSize, _ rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width / rhs.width, height: lhs.height / rhs.height)
    }
}

//class StatsPortalGeneral {
//    var data = [Datum]()
//
//    init(backgroundSprite: SKSpriteNode) {
//        (0..<5).forEach {
//            data.append(Datum(backgroundSprite, slot: $0, exampleText: "Barmy -45.4", getter: carbalizer))
//        }
//
//        data.forEach { $0.update() }
//    }
//
//    var carbalized: Double { return  Double.random(in: -42...42) }
//    func carbalizer() -> String {
//        let f = String(format: "%-.2f", carbalized)
//        return "Barmy \(f)"
//    }
//}
//
//extension StatsPortalGeneral {
//    class Datum {
//        typealias Getter = () -> String
//
//        private let backgroundSprite: SKSpriteNode
//        fileprivate let getter: Getter
//        private let node: SKLabelNode
//
//        init(_ backgroundSprite: SKSpriteNode, slot: Int, exampleText: String, getter: @escaping Getter) {
//            self.backgroundSprite = backgroundSprite
//
//            let xUnscale: CGFloat = 1.0 /// (backgroundSprite.xScale * backgroundSprite.xScale)
//            let yUnscale: CGFloat = 1.0 /// (backgroundSprite.yScale * backgroundSprite.yScale)
//
//            self.node = SKLabelNode(text: "")
//            self.node.fontColor = .green
//            self.node.fontSize = 10
//            self.node.fontName = "Courier New"
//
//            let desperateHack = CGFloat(2 - slot) * backgroundSprite.frame.size.height / 1.75
//            self.node.position.y += desperateHack - backgroundSprite.frame.size.height / 5.0
//            self.node.position.x -= backgroundSprite.frame.size.width / 3.0
//
//            (self.node.xScale, self.node.yScale) = (xUnscale, yUnscale)
//
//            self.getter = getter
//
//            backgroundSprite.addChild(self.node)
//        }
//
//        func update() {
//            self.node.text = getter()
//        }
//    }
//}

//class StatsPortal {
////    var generalPurposePortals = [StatsPortalGeneral]()
//    var histogramPortals = [StatsPortalHistogram]()
//    let sprite: SKSpriteNode
//    let subportals: [SKSpriteNode]
//
//    enum PortalType {
//        case arkonPortal, netPortal, statsPortal
//    }
//
//    enum StatsPortalType: Int, CaseIterable {
//        case clock, histogram1, histogram2
//        case gp1, gp2, gp3, gp4, gp5, gp6
//    }
//
//    init(_ sprite: SKSpriteNode, portalServer: PortalServer) {
//        self.sprite = sprite
//
//        let positions = [
//            (-1, 1), (0, 1), (1, 1),
//            (-1, 0), (0, 0), (1, 0),
//            (-1, -1), (0, -1), (1, -1)
//        ]
//
//        let scaleFactor = 1.0 / (CGSize(width: sprite.xScale, height: sprite.yScale) * 3.0)
//        let subportalSize = sprite.frame.size * scaleFactor
//
//        subportals = (0..<9).map { positionFactor in
//            let p = portalServer.addPortal(
//                to: sprite, size: subportalSize, scale: CGPoint(x: 0.3, y: 0.3), color: .blue
//            )
//
//            portalServer.setPosition(
//                p, at: (subportalSize * positions[positionFactor]).asPoint()
//            )
//
//            return p
//        }
//    }
//}

//class GameScene: SKScene {
//    static var shared: SKScene!
//
//    var arkonsPortal: SKSpriteNode!
//    var netPortal: SKSpriteNode!
//    var portalServer: PortalServer!
//
//    override func didMove(to view: SKView) {
//        GameScene.shared = self
//
//        arkonsPortal = childNode(withName: "arkonsPortal") as? SKSpriteNode
//        netPortal = childNode(withName: "netPortal") as? SKSpriteNode
//        let stats00_00 = childNode(withName: "stats00_00") as? SKLabelNode
//        stats00_00?.text = "Llama count"
//
//        var mthb = [SKSpriteNode]()
//        enumerateChildNodes(withName: "mutationTypesHistogramBars") { (node, _) in
//            if let n = node as? SKSpriteNode { mthb.append(n); n.color = .blue }
//        }
//
//        //        let arkonsCamera = childNode(withName: "arkonsCamera")!
//        let blubber = childNode(withName: "blubber")!
//        let scoot = SKAction.move(by: CGVector(dx: 100, dy: 0), duration: 1.0)
//        let seq = SKAction.sequence([scoot, scoot.reversed()])
//        blubber.run(SKAction.repeatForever(seq))
//
//        //        portalServer = PortalServer(scene: self)
//        //
//        //        arkonsPortal = portalServer.addPortal(
//        //            to: self,
//        //            size: self.frame.size * CGSize(width: 0.5, height: 1.0),
//        //            scale: CGPoint(x: 0.5, y: 0.5),
//        //            color: .green
//        //        )
//        //
//        //        var x = CGFloat(-self.frame.size.width / 4)
//        //        var y = CGFloat(0.0)
//        //        portalServer.setPosition(arkonsPortal, at: CGPoint(x: x, y: y))
//        //
//        //        netPortal = portalServer.addPortal(
//        //            to: self,
//        //            size: self.frame.size / 2.0,
//        //            scale: CGPoint(x: 0.5, y: 0.5),
//        //            color: .yellow
//        //        )
//        //
//        //        x = self.frame.size.width / 4
//        //        y = self.frame.size.height / 4
//        //        portalServer.setPosition(netPortal, at: CGPoint(x: x, y: y))
//        //
//        //        let statsPortalSprite = portalServer.addPortal(
//        //            to: self,
//        //            size: self.frame.size / 2.0,
//        //            scale: CGPoint(x: 0.5, y: 0.5),
//        //            color: .white
//        //        )
//        //
//        //        x = self.frame.size.width / 4
//        //        y = -self.frame.size.height / 4
//        //        portalServer.setPosition(statsPortalSprite, at: CGPoint(x: x, y: y))
//        //
//        //        self.statsPortal = StatsPortal(statsPortalSprite, portalServer: portalServer)
//    }
//
//    override func update(_ currentTime: TimeInterval) {
//    }
//}
