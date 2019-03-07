import Foundation
import SpriteKit

class Arkon {
    let birthday: TimeInterval
    var cOffspring = 0
    var apoptosizeAction: SKAction!
    let fishNumber: Int
    let fNet: FNet
    let genome: Genome
    var hasGivenBirth = false
    var health = 5.0
    var isAlive = false
    var isShowingNet = false
    var kNet: KNet!
    var targetManna: (id: String, position: CGPoint)?
    var motorOutputs: MotorOutputs!
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

    init?(parentFishNumber: Int?, genome: Genome, fNet: FNet, portal: SKSpriteNode) {
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

        genome.genomeCounter.arkonWhoseGenomeThisIs = self.fishNumber

        // Dark parts all set up; SpriteKit will add a sprite and
        // launch on the next display cycle, unless, of course, we didn't
        // survive the test signal.

        if !arkonSurvived { return nil }
    }

    deinit {
        genome.reset(releaseGenes: true)
        if self.isAlive { Arkonery.shared.cLivingArkons -= 1 }
        self.isAlive = false // Tidiness/superstition
    }
}
