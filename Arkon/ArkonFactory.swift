import Foundation
import SpriteKit

class ArkonFactory: NSObject {
    static var theAboriginalGenome: [GeneProtocol]?

    static func makeMeatyNeuron(_ channelNumber: Int) -> [GeneProtocol] {
        return [GeneProtocol](
            arrayLiteral: gNeuron(), gActivatorFunction(.boundidentity), gBias(Double.random(in: -1..<1))
            ) + (0..<12).map { makeUpConnectorGene($0) } + [gDownConnector(channelNumber)]
    }

    static func makeMeatyNeurons(_ cNeurons: Int) -> [GeneProtocol] {
        return (0..<cNeurons).map {
            makeMeatyNeuron($0)
        }.reduce([GeneProtocol]()) {
            var dollarZero = $0; dollarZero.append(contentsOf: $1); return dollarZero
        }
    }

    static func makeUpConnector(_ channel: Int) -> UpConnector {
        let c = makeUpConnectorChannel(channel)
        let w = makeUpConnectorWeight()
        let a = makeUpConnectorAmplifier()

        return UpConnector(c, w, a)
    }

    static func makeUpConnectorAmplifier() -> UpConnectorAmplifier {
        return UpConnectorAmplifier(amplificationMode: .none, multiplier: 1)
    }

    static func makeUpConnectorChannel(_ channel: Int) -> UpConnectorChannel {
        let topOfRange = channel
        return UpConnectorChannel(channel: channel, topOfRange: topOfRange)
    }

    static func makeUpConnectorChannels(_ range: Range<Int>) -> [UpConnectorChannel] {
        return range.map { makeUpConnectorChannel($0) }
    }

    static func makeUpConnectorGene(_ channel: Int) -> gUpConnector {
        let upConnector = makeUpConnector(channel)
        return gUpConnector(upConnector)
    }

    static func makeUpConnectorWeight() -> UpConnectorWeight {
        return UpConnectorWeight(weight: Double.random(in: -1..<1))
    }

    static func getAboriginalGenome() -> [GeneProtocol] {
        if let g = theAboriginalGenome { return g }

        let upConnectorChannels = makeUpConnectorChannels(-1..<(12 - 1))

        let upConnectors = upConnectorChannels.map { makeUpConnector($0.channel) }

        let gUpConnectors = upConnectors.map { return gUpConnector($0) }

        func makeLayer(_ cNeurons: Int) -> [GeneProtocol] {
            return [GeneProtocol](arrayLiteral: gLayer()) + makeMeatyNeurons(cNeurons)
        }

        theAboriginalGenome = makeLayer(9) + makeLayer(7) + makeLayer(5)
        return theAboriginalGenome!
    }

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
