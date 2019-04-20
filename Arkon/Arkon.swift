import Foundation
import SpriteKit

class Arkon {
    var fishNumber: Int {
        get { return status.fishNumber }
    }

    let fNet: FNet
    let genome: [GeneProtocol]
    var hunger: CGFloat = 0
    let parentFishNumber: Int?
    var portal: SKSpriteNode
    let signalDriver: KSignalDriver
    weak var sprite: Karamba!
    var status: Status

    var zerosAlready = false

    init?(parentFishNumber: Int?, genome: [GeneProtocol], fNet: FNet, portal: SKSpriteNode) {
        self.status = Status(fishNumber: ArkonCentralDark.selectionControls.theFishNumber)
        ArkonCentralDark.selectionControls.theFishNumber += 1

        self.portal = hardBind(
            Display.shared.scene?.childNode(withName: "arkons_portal") as? SKSpriteNode
        )

        self.parentFishNumber = parentFishNumber
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
//        print("arkon deinit 1", fishNumber, terminator: "")
//        sprite = nil
//        if !(sprite?.isAlive ?? false) { return }
//        print(" arkon deinit 2", fishNumber, terminator: "")
//
//        if status.isOldest { ArkonFactory.shared.cGenerations += 1 }
//        print(" arkon deinit 3", fishNumber, terminator: "")
//
//        ArkonFactory.shared.logHistogram.addSample(status.age)
//        ArkonFactory.shared.auxLogHistogram.addSample(genome.count)
//        print(" arkon deinit 4", fishNumber, terminator: "")
    }
}
