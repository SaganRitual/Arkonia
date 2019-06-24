import Foundation

enum Assembler {
    static public func makeRandomGenome(cGenes: Int) -> [GeneProtocol] {
        let genome = (0..<cGenes).map { _ in GeneCore.makeRandomGene() }

        return genome
    }

    static var bias = 1.0
    static func baseNeuronSnippet(channel: Int) -> [GeneProtocol] {
        bias *= -1

        var transport: [GeneProtocol] = [
            gNeuron(), gActivatorFunction(.boundidentity), gBias(bias)
        ]

        transport += (0..<ArkoniaCentral.cSenseNeurons).map {
            let amplifier = UpConnectorAmplifier(amplificationMode: .none, multiplier: 1)

            let channel = UpConnectorChannel(
                channel: $0, topOfRange: GeneCore.upConnectorChannelTopOfRange
            )

            let weight = UpConnectorWeight(weight: 1.0)

            return gUpConnector(UpConnector(channel, weight, amplifier))
         }

        return transport
    }

    static func makeOneLayer(cNeurons: Int) -> [GeneProtocol] {
        let marker = [gLayer()]
        let neurons = (0..<cNeurons).flatMap { channel in
            baseNeuronSnippet(channel: channel)
        }

        return marker + neurons
    }

}
