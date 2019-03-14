import Foundation

enum GeneCore {
    case int(_ rawValue: Int, _ range: Int, _ isMutatedCopy: Bool)
    case double(_ rawValue: Double, _ isMutatedCopy: Bool)
    case empty
    case activator(_ functionName: AFn.FunctionName, _ isMutatedCopy: Bool)
    case upConnector(_ channel: Int, _ topOfRange: Int, _ weight: Double, _ isMutatedCopy: Bool)

    static var cLiveGenes = 0
    static var highWaterMark = 0

    static let downConnectorTopOfRange = 1000
    static let hoxTopOfRange = 10
    static let lockTopOfRange = 10
    static let upConnectorChannelTopOfRange = 1000

    static func getWeightedRandomGene() -> GeneType {
        let weightMap: [GeneType : Int] = [
            .activator: 10, .bias: 10, .downConnector: 10, .hox: 1, .lock: 1, .layer: 1,
            .neuron: 10/*, .policy: 1, .skipAnyType: 1, .skipOneType: 1*/, .upConnector: 10
        ]

        let weightRange = weightMap.reduce(0, { return $0 + $1.value })
        let randomValue = Int.random(in: 0..<weightRange)

        var runningTotal = 0
        for (key, value) in weightMap {
            runningTotal += value
            if runningTotal > randomValue { return key }
        }

        fatalError()
    }

    static func makeRandomGene() -> GeneProtocol {
        let geneType = getWeightedRandomGene()

        switch geneType {
        case .activator:     return gActivatorFunction.makeRandomGene()
        case .bias:          return gBias.makeRandomGene()
        case .downConnector: return gDownConnector.makeRandomGene()
        case .hox:           return gHox.makeRandomGene()
        case .lock:          return gLock.makeRandomGene()
        case .layer:         return gLayer.makeRandomGene()
        case .neuron:        return gNeuron.makeRandomGene()
//        case .policy:        return gPolicy.makeRandomGene()
//        case .skipAnyType:   return gSkipAnyType.makeRandomGene()
//        case .skipOneType:   return gSkipOneType.makeRandomGene()
        case .upConnector:   return gUpConnector.makeRandomGene()
        }
    }

    static func mutated(from gene: GeneProtocol) -> GeneProtocol {
        switch gene {
        case is gActivatorFunction:     return gActivatorFunction.makeRandomGene()
        case is gBias:          return gBias.makeRandomGene()
        case is gDownConnector: return gDownConnector.makeRandomGene()
        case is gHox:           return gHox.makeRandomGene()
        case is gLock:          return gLock.makeRandomGene()
        case is gLayer:         return gLayer.makeRandomGene()
        case is gNeuron:        return gNeuron.makeRandomGene()
            //        case .policy:        return gPolicy.makeRandomGene()
            //        case .skipAnyType:   return gSkipAnyType.makeRandomGene()
        //        case .skipOneType:   return gSkipOneType.makeRandomGene()
        case is gUpConnector:   return gUpConnector.makeRandomGene()
        default: preconditionFailure()
        }
    }

    static func mutated(from geneCore: GeneCore) -> GeneCore {
        switch geneCore {
        case let .double(currentRawValue, _):
            let newRawValue = geneCore.mutated(from: currentRawValue)
            return GeneCore.double(newRawValue, newRawValue != currentRawValue)

        case let .int(currentRawValue, topOfRange, _):
            let newRawValue = geneCore.mutated(from: currentRawValue, topOfRange: topOfRange)
            return GeneCore.int(newRawValue, topOfRange, newRawValue != currentRawValue)

        case let .activator(currentFunctionName, _):
            let newFunctionName = nok(AFn.FunctionName.allCases.randomElement())
            return GeneCore.activator(newFunctionName, newFunctionName != currentFunctionName)

        case let .upConnector(currentChannel, topOfRange, currentWeight, _):
            let newChannel = geneCore.mutated(from: currentChannel, topOfRange: topOfRange)
            let newWeight = geneCore.mutated(from: currentWeight)

            let channelIsMutated = newChannel != currentChannel
            let weightIsMutated = newWeight != currentWeight
            let isMutatedCopy = channelIsMutated || weightIsMutated

            return GeneCore.upConnector(newChannel, topOfRange, newWeight, isMutatedCopy)

        default: preconditionFailure()
        }
    }

    fileprivate func mutated(from currentValue: Double) -> Double {
        // 75% of the time, you get a copy
        if Double.random(in: 0..<1) < 0.75 {
            return currentValue
        }

        return Double.random(in: 0..<1)
    }

    fileprivate func mutated(from currentValue: Int, topOfRange: Int) -> Int {
        // 75% of the time, you get a copy
        if Double.random(in: 0..<1) < 0.75 { return currentValue }

        return Int.random(in: 0..<topOfRange)
    }

    fileprivate func mutated(from currentChannel: Int, topOfRange: Int, currentWeight: Double)
        -> (Int, Double)
    {
        // 75% of the time, you get a copy
        if Double.random(in: 0..<1) < 0.75 { return (currentChannel, currentWeight) }

        let mutateChannel = Bool.random()
        let newChannel = mutateChannel ?
            mutated(from: currentChannel, topOfRange: topOfRange) : currentChannel

        let mutateWeight = Bool.random()
        let newWeight = mutateWeight ? mutated(from: currentWeight) : currentWeight

        return (newChannel, newWeight)
    }

    fileprivate func mutated(from functionName: AFn.FunctionName) -> AFn.FunctionName {
        // 75% of the time, you get a copy
        if Double.random(in: 0..<1) < 0.75 { return functionName }

        guard let newFunctionName = AFn.FunctionName.allCases.randomElement() else {
            preconditionFailure()
        }

        return newFunctionName
    }
}
