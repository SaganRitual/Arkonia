import Foundation
import SpriteKit

class Arkon {
    static func getAges() -> [TimeInterval] {
        return PortalServer.shared!.arkonsPortal.children.compactMap {
            ($0 as? SKSpriteNode)?.arkon?.myAge
        }
    }

    static var medianLiveArkonAge: TimeInterval {
        let ages = getAges().sorted()
        return ages.isEmpty ? 0 : ages[ages.count / 2]
    }

    static var currentAgeOfOldestArkon: TimeInterval = 0.0 { willSet {
        if newValue > recordArkonAge { recordArkonAge = newValue }
    }}

    static var averageAgeOfLivingArkons: TimeInterval {
        let sprites = PortalServer.shared!.arkonsPortal.children.compactMap { $0 as? SKSpriteNode }
        let totalAge = sprites.reduce(0) { $0 + ($1.arkon?.myAge ?? 0.0) }
        return totalAge / TimeInterval(ArkonFactory.shared.cLiveArkons)
    }

    static var recordArkonAge: TimeInterval = 0.0

    static var currentHealthOfOldestArkon: Double = 0.0

    static var currentCOffspring = 0 { willSet {
        if newValue > recordArkonOffspring { recordArkonOffspring = newValue }
    } }

    static var recordArkonOffspring = 0

    static func getSeniorHealthStats() -> String {
        return String(
            format: "Health: %.2f\nOffspring: %d\nRecord: %d\nI suck at UI stuff",
                Arkon.currentHealthOfOldestArkon, Arkon.currentCOffspring, Arkon.recordArkonOffspring
        )
    }

    let birthday: TimeInterval
    var cOffspring = 0 { willSet { if self.isOldestArkon { Arkon.currentCOffspring = newValue } } }
    var apoptosizeAction: SKAction!
    let fishNumber: Int
    let fNet: FNet
    let genome: [GeneProtocol]
    var hasGivenBirth = false
    var health = 10.0
    var isAlive = false
    var isOldestArkon = false
    var isShowingNet = false
    var kNet: KNet!
    var targetManna: (id: String, position: CGPoint)?
    var motorOutputs: MotorOutputs!
    var myAgeAtLastSpawn: TimeInterval = 0
    var observer: NSObjectProtocol?
    let parentFishNumber: Int?
    var portal: SKSpriteNode!
    let signalDriver: KSignalDriver
    var sprite: SKSpriteNode!
    var tickAction: SKAction!

    var isHealthy: Bool { return health > 0 }

    var isInBounds: Bool {
        let relativeToPortal = portal.convert(sprite.frame.origin, to: portal.parent!)

        let w = sprite.size.width * portal.xScale
        let h = sprite.size.height * portal.yScale
        let scaledSize = CGSize(width: w, height: h)

        let arkonRectangle = CGRect(origin: relativeToPortal, size: scaledSize)

        // Remember: get the scene frame rather than the portal frame because
        // that's how big the portal's children think the portal is. We can't
        // use the portal's frame, because it is doing its own thing due to scaling.
        return portal.frame.contains(arkonRectangle)
    }

    var myAge: TimeInterval { return Display.shared.currentTime - self.birthday }

    init?(parentFishNumber: Int?, genome: [GeneProtocol], fNet: FNet, portal: SKSpriteNode) {
        self.fishNumber = ArkonCentralDark.selectionControls.theFishNumber
        ArkonCentralDark.selectionControls.theFishNumber += 1

        self.parentFishNumber = parentFishNumber
        self.birthday = Display.shared.currentTime

        self.portal = portal

        self.genome = genome
        self.fNet = fNet
        self.signalDriver = KSignalDriver(idNumber: self.fishNumber, fNet: fNet)

        let arkonSurvived = signalDriver.drive(
            sensoryInputs: Array.init(
                repeating: 0, count: ArkonCentralDark.selectionControls.cSenseNeurons
            )
        )

        GeneCore.cLiveGenes += self.genome.count

        // Dark parts all set up; SpriteKit will add a sprite and
        // launch on the next display cycle, unless, of course, we didn't
        // survive the test signal.

        if !arkonSurvived { return nil }
    }

    deinit {
        GeneCore.cLiveGenes -= self.genome.count
        if self.isOldestArkon { ArkonFactory.shared.cGenerations += 1 }
        if self.isAlive { ArkonFactory.shared.cLiveArkons -= 1 }

        self.isAlive = false // Tidiness/superstition
    }
}
