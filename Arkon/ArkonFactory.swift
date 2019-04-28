import Foundation
import SpriteKit

class ArkonFactory: NSObject {
    static func getAboriginalGenome() -> [GeneProtocol] {
        return Assembler.makeRandomGenome(cGenes: Int.random(in: 200..<500))
    }

    static var shared: ArkonFactory!
    static let scale: CGFloat = 0.25

    var cAttempted = 0
    var cBirthFailed = 0
    var cGenerations = 0
    var cPending = 0
    var hiWaterCLiveArkons = 0
    var hiWaterGenomeLength = 0

//    var cLiveArkons: Int { return World.shared.population.getCLiveArkons() }

    var tickWorkItem: DispatchWorkItem!

    static let karambaSerializerQueue = DispatchQueue(label: "light.karamba", qos: .background)
    static let karambaStimulusQueue =
        DispatchQueue(label: "dark.karamba", qos: .background, attributes: .concurrent)

    func makeArkon(parentFishNumber: Int?, parentGenome: [GeneProtocol]) -> Karamba? {
        let newGenome = Mutator.shared.mutate(parentGenome)

        guard let fNet = FDecoder.shared.decode(newGenome), !fNet.layers.isEmpty
            else { return nil }

        guard let arkon = Karamba(
            geneticParentFishNumber: parentFishNumber, geneticParentGenome: parentGenome,
            genome: newGenome, fNet: fNet
        ) else { return nil }

        return arkon
    }
}
