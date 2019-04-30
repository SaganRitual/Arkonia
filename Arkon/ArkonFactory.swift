import Foundation
import SpriteKit

class ArkonFactory: NSObject {
    // swiftlint:disable function_body_length
    static func getAboriginalGenome() -> [GeneProtocol] {
//        return Assembler.makeRandomGenome(cGenes: Int.random(in: 200..<500))

        let minusOneChannel = UpConnectorChannel(channel: -1, topOfRange: -1)

        let upConnectorChannels: [UpConnectorChannel] = [
            UpConnectorChannel(channel: 0, topOfRange: 0),
            UpConnectorChannel(channel: 1, topOfRange: 1),
            UpConnectorChannel(channel: 2, topOfRange: 2),
            UpConnectorChannel(channel: 3, topOfRange: 3),
            UpConnectorChannel(channel: 4, topOfRange: 4),
            UpConnectorChannel(channel: 5, topOfRange: 5),
            UpConnectorChannel(channel: 6, topOfRange: 6),
            UpConnectorChannel(channel: 7, topOfRange: 7),
            UpConnectorChannel(channel: 8, topOfRange: 8),
            UpConnectorChannel(channel: 9, topOfRange: 9),
            UpConnectorChannel(channel: 10, topOfRange: 10),
            UpConnectorChannel(channel: 11, topOfRange: 11)
        ]

        let upConnectorWeight = UpConnectorWeight(weight: 1.0)
        let upConnectorAmplifier = UpConnectorAmplifier(amplificationMode: .none, multiplier: 1.0)

        let upConnectors = upConnectorChannels.map { upConnectorChannel in
            return UpConnector(upConnectorChannel, upConnectorWeight, upConnectorAmplifier)
        }

        let minusOneConnector = UpConnector(minusOneChannel, upConnectorWeight, upConnectorAmplifier)

        let genome: [GeneProtocol] = [
            gLayer(),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(minusOneConnector), gUpConnector(upConnectors[0]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[0]), gUpConnector(upConnectors[1]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[1]), gUpConnector(upConnectors[2]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[4]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[4]), gUpConnector(upConnectors[5]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[7]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[7]), gUpConnector(upConnectors[8]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[8]), gUpConnector(upConnectors[9]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[9]), gUpConnector(upConnectors[10]),

            gLayer(),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[0]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[1]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[2]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[3]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[4]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[5]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[6]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[7]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[8]),

            gLayer(),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(minusOneConnector), gUpConnector(upConnectors[0]), gDownConnector(0),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[2]), gDownConnector(1),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[3]), gDownConnector(2),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[4]), gDownConnector(1), gDownConnector(3),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[5]), gDownConnector(2),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[6]), gDownConnector(3),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[6]), gUpConnector(upConnectors[7]), gDownConnector(4)
        ]

        return genome
    }
    // swiftlint:enable function_body_length

    static var shared: ArkonFactory!
    static let scale: CGFloat = 0.25

    var cAttempted = 0
    var cBirthFailed = 0
    var cGenerations = 0
    var cPending = 0
    var hiWaterCLiveArkons = 0
    var hiWaterGenomeLength = 0

    func getArkon(_ fishNumber: Int) -> Karamba? {
        let scene = hardBind(Display.shared.scene)
        guard let portal = scene.childNode(withName: "arkons_portal") as? SKSpriteNode
            else { return nil }

        return portal.children.first {
            guard let parentArkon = $0 as? Karamba else { return false }
            return parentArkon.fishNumber == fishNumber
        } as? Karamba
    }

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
