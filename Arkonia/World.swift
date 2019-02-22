import Foundation
import SpriteKit

typealias ArkonFactory = AAFactory

class World {
    static var shared: World!

    static let cSenseNeurons = 1
    static let cMotorNeurons = 1

    var aboriginalGenome: Genome?
    var arkons = [Arkon]()
    var arkonFactory: ArkonFactory?
    var portal: SKNode

    enum LaunchStage { case unready, readyForInit, flying }
    var launchStage = LaunchStage.unready

    init() {
        launchStage = .readyForInit
        portal = Display.shared.getPortal(quadrant: 1)

        World.shared = self
    }

    private func deadArkonCleanup() { arkons.removeAll { !$0.isAlive } }

    private func createStarterPopulation() {
        World.setSelectionControls()

        self.arkonFactory = AAFactory()
        self.aboriginalGenome = Assembler.makeRandomGenome(cGenes: 200)

        self.arkons = (0..<100).compactMap {
            makeArkon(fishNumber: $0, genome: aboriginalGenome!, mutate: true, portal: self.portal)
        }

        self.arkons.forEach { $0.comeToLife() }
        self.launchStage = .flying
    }

    public func getAboriginal() -> Arkon {
        let genome = self.aboriginalGenome !! { preconditionFailure() }

        let aboriginal = makeArkon(
            fishNumber: 0, genome: genome, mutate: false, portal: self.portal
        ) !! { preconditionFailure("Aboriginal should survive birth") }

        return aboriginal
    }

    func makeArkon(fishNumber: Int, genome: Genome, mutate: Bool, portal: SKNode) -> Arkon? {
        let (newGenome, fNet_) = makeNet(genome: genome, mutate: mutate)
        guard let fNet = fNet_, !fNet.layers.isEmpty else { return nil }

        // Subject now owns the fNet and the newGenome
        return Arkon(fishNumber: fishNumber, genome: newGenome, fNet: fNet, portal: portal)
    }

    func makeNet(genome: Genome, mutate: Bool) -> (Genome, FNet?) {
        let newGenome = genome.copy()
        if mutate { ArkonCentralDark.mutator.mutate(newGenome) }
        let e = FDecoder.shared.decode(newGenome)
        return (newGenome, e as? FNet)
    }

    static func setSelectionControls() {
        ArkonCentralDark.selectionControls.cSenseNeurons = AAGoalSuite.cSenseNeurons
        ArkonCentralDark.selectionControls.cLayersInStarter = 2
        ArkonCentralDark.selectionControls.cMotorNeurons = AAGoalSuite.cMotorNeurons
        ArkonCentralDark.selectionControls.cGenerations = 10000
    }

    func update(_ currentTime: TimeInterval, for scene: SKScene) -> LaunchStage {
        switch launchStage {
        case .unready:
            break

        case .readyForInit:
            precondition(self.arkons.isEmpty)
            self.portal.run(SKAction.run { [unowned self] in self.createStarterPopulation() })

        case .flying:
            deadArkonCleanup()
        }

        return self.launchStage
    }
}
