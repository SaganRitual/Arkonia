import Foundation
import SpriteKit

class ArkonFactory: NSObject {
    // swiftlint:disable function_body_length
    static func getAboriginalGenome() -> [GeneProtocol] {
//        return Assembler.makeRandomGenome(cGenes: Int.random(in: 200..<500))

        let upConnectorChannels: [Int: UpConnectorChannel] = [
            0: UpConnectorChannel(channel: 0, topOfRange: 12),
            1: UpConnectorChannel(channel: 1, topOfRange: 12),
            2: UpConnectorChannel(channel: 2, topOfRange: 12),
            3: UpConnectorChannel(channel: 3, topOfRange: 12),
            4: UpConnectorChannel(channel: 4, topOfRange: 12),
            5: UpConnectorChannel(channel: 5, topOfRange: 12),
            6: UpConnectorChannel(channel: 6, topOfRange: 12),
            7: UpConnectorChannel(channel: 7, topOfRange: 12),
            8: UpConnectorChannel(channel: 8, topOfRange: 12),
            9: UpConnectorChannel(channel: 9, topOfRange: 12),
            10: UpConnectorChannel(channel: 10, topOfRange: 12),
            11: UpConnectorChannel(channel: 11, topOfRange: 12),
            -12: UpConnectorChannel(channel: -12, topOfRange: 12),
            -11: UpConnectorChannel(channel: -11, topOfRange: 12),
            -10: UpConnectorChannel(channel: -10, topOfRange: 12),
            -9: UpConnectorChannel(channel: -9, topOfRange: 12),
            -8: UpConnectorChannel(channel: -8, topOfRange: 12),
            -7: UpConnectorChannel(channel: -7, topOfRange: 12),
            -6: UpConnectorChannel(channel: -6, topOfRange: 12),
            -5: UpConnectorChannel(channel: -5, topOfRange: 12),
            -4: UpConnectorChannel(channel: -4, topOfRange: 12),
            -3: UpConnectorChannel(channel: -3, topOfRange: 12),
            -2: UpConnectorChannel(channel: -2, topOfRange: 12),
            -1: UpConnectorChannel(channel: -1, topOfRange: 12)
        ]

        let upConnectorWeight = UpConnectorWeight(weight: 1.0)
        let upConnectorAmplifier = UpConnectorAmplifier(amplificationMode: .none, multiplier: 1.0)

        let upConnectors = upConnectorChannels.map { (_, upConnectorChannel) in
            return UpConnector(upConnectorChannel, upConnectorWeight, upConnectorAmplifier)
        }

        let genome: [GeneProtocol] = [
//            gLayer(),
//                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[23]), gUpConnector(upConnectors[14]), gUpConnector(upConnectors[5]), gUpConnector(upConnectors[20]),
//                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[22]), gUpConnector(upConnectors[13]), gUpConnector(upConnectors[4]), gUpConnector(upConnectors[19]),
//                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[21]), gUpConnector(upConnectors[12]), gUpConnector(upConnectors[3]), gUpConnector(upConnectors[18]),
//                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[20]), gUpConnector(upConnectors[11]), gUpConnector(upConnectors[2]), gUpConnector(upConnectors[17]),
//                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[19]), gUpConnector(upConnectors[10]), gUpConnector(upConnectors[1]),
//                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[18]), gUpConnector(upConnectors[9]), gUpConnector(upConnectors[0]),
//                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[17]), gUpConnector(upConnectors[8]), gUpConnector(upConnectors[23]),
//                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[16]), gUpConnector(upConnectors[7]), gUpConnector(upConnectors[22]),
//                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[15]), gUpConnector(upConnectors[6]), gUpConnector(upConnectors[21]),

            gLayer(),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[0]), gUpConnector(upConnectors[5]), gUpConnector(upConnectors[0]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[1]), gUpConnector(upConnectors[4]), gUpConnector(upConnectors[1]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[2]), gUpConnector(upConnectors[3]), gUpConnector(upConnectors[2]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[3]), gUpConnector(upConnectors[2]), gUpConnector(upConnectors[3]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[4]), gUpConnector(upConnectors[1]), gUpConnector(upConnectors[4]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[5]), gUpConnector(upConnectors[0]), gUpConnector(upConnectors[5]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[6]), gUpConnector(upConnectors[11]), gUpConnector(upConnectors[6]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[7]), gUpConnector(upConnectors[10]), gUpConnector(upConnectors[7]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[8]), gUpConnector(upConnectors[9]), gUpConnector(upConnectors[8]),

            gLayer(),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[12]), gUpConnector(upConnectors[0]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[13]), gUpConnector(upConnectors[1]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[14]), gUpConnector(upConnectors[2]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[15]), gUpConnector(upConnectors[3]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[16]), gUpConnector(upConnectors[4]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[17]), gUpConnector(upConnectors[5]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[18]), gUpConnector(upConnectors[6]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[19]), gUpConnector(upConnectors[7]),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[20]), gUpConnector(upConnectors[8]),

            gLayer(),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[0]), gUpConnector(upConnectors[7]), gUpConnector(upConnectors[14]), gDownConnector(0),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[1]), gUpConnector(upConnectors[8]), gUpConnector(upConnectors[15]), gDownConnector(1),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[2]), gUpConnector(upConnectors[9]), gUpConnector(upConnectors[16]), gDownConnector(2),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[3]), gUpConnector(upConnectors[10]), gDownConnector(1), gDownConnector(3),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[4]), gUpConnector(upConnectors[11]), gUpConnector(upConnectors[17]), gDownConnector(2),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(-1.0), gUpConnector(upConnectors[5]), gUpConnector(upConnectors[12]), gUpConnector(upConnectors[18]), gDownConnector(3),
                gNeuron(), gActivatorFunction(.boundidentity), gBias(+1.0), gUpConnector(upConnectors[6]), gUpConnector(upConnectors[13]), gUpConnector(upConnectors[19]), gDownConnector(4)
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
