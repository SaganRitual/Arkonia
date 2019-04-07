import Foundation
import SpriteKit

class Arkon {
    var apoptosizeAction: SKAction!
    var fishNumber: Int {
        get { return status.fishNumber }
    }

    var contactedBodies = [SKPhysicsBody]()
    let fNet: FNet
    let genome: [GeneProtocol]
    var hunger: CGFloat = 0
    let parentFishNumber: Int?
    var portal = PortalServer.shared.arkonsPortal
    var scheduledActions = [SKAction]()
    let signalDriver: KSignalDriver
    var sprite: Karamba!
    var status: Status
    var targetManna: (id: String, position: CGPoint)?
    var tickAction: SKAction!
    var sensedBodies = [SKPhysicsBody]()

    var zerosAlready = false

    init?(parentFishNumber: Int?, genome: [GeneProtocol], fNet: FNet, portal: SKSpriteNode) {
        self.status = Status(fishNumber: ArkonCentralDark.selectionControls.theFishNumber)
        ArkonCentralDark.selectionControls.theFishNumber += 1

        self.parentFishNumber = parentFishNumber
        self.portal = portal
        self.genome = genome
        self.fNet = fNet

        self.signalDriver = KSignalDriver(idNumber: self.status.fishNumber, fNet: fNet)

        let arkonSurvived = signalDriver.drive(
            sensoryInputs: Array.init(
                repeating: 0, count: World.cSenseNeurons
            )
        )

        self.status.postInit()

        World.shared.populationChanged = true

        // Dark parts all set up; SpriteKit will add a sprite and
        // launch on the next display cycle, unless, of course, we didn't
        // survive the test signal.

        if !arkonSurvived { return nil }
    }

    deinit {
        if !status.isAlive { return }

        if status.isOldest { ArkonFactory.shared.cGenerations += 1 }

        ArkonFactory.shared.logHistogram.addSample(status.age)
        ArkonFactory.shared.auxLogHistogram.addSample(genome.count)
    }
}
