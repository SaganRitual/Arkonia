import Foundation

class Gene: CustomDebugStringConvertible {
    static var cLiveGenes = 0 { willSet {
        if newValue > Gene.highWaterMark { highWaterMark = newValue }
    }}

    static var highWaterMark = 0
    private static var idNumber = 0

    let idNumber: Int
    let type: GeneType

    var next: Gene?
    weak var prev: Gene?

    var description: String { Gene.missingOverrideInSubclass() }
    var debugDescription: String { return description }

    static func init_(_ type: GeneType) -> (Int, GeneType) {
        defer {
            Gene.idNumber += 1
            Gene.cLiveGenes += 1
        }

        let idNumber = Gene.idNumber
        return (idNumber, type)
    }

    init(_ type: GeneType) {
        (self.idNumber, self.type) = Gene.init_(type)
        print("s(\(idNumber))(\(Gene.cLiveGenes))", terminator: "")
    }

    init(_ copyFrom: Gene) { Gene.missingOverrideInSubclass() }

    deinit { Gene.cLiveGenes -= 1; print("g(\(idNumber))(\(Gene.cLiveGenes))", terminator: "") }

    func copy() -> Gene { Gene.missingOverrideInSubclass() }
    func isMyself(_ thatGuy: Gene?) -> Bool { return self === thatGuy }

    // swiftmint:disable cyclomatic_complexity
    /*
    class func getWeightedRandomGene() -> GeneType {
        let weightMap: [GeneType : Int] = [
            .activator: 10, .bias: 10, .downConnector: 10, .hox: 1, .lock: 1, .layer: 1,
            .neuron: 10, .policy: 1, .skipAnyType: 1, .skipOneType: 1, .upConnector: 10
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
    */
    /*
    class func makeRandomGene() -> Gene {

        let geneType = getWeightedRandomGene()

        switch geneType {
        case .activator:     return gActivatorFunction.makeRandomGene()
        case .bias:          return gBias.makeRandomGene()
//        case .downConnector: return gDownConnector.makeRandomGene()
//        case .hox:           return gHox.makeRandomGene()
//        case .lock:          return gLock.makeRandomGene()
//        case .layer:         return gLayer.makeRandomGene()
//        case .neuron:        return gNeuron.makeRandomGene()
//        case .policy:        return gPolicy.makeRandomGene()
//        case .skipAnyType:   return gSkipAnyType.makeRandomGene()
//        case .skipOneType:   return gSkipOneType.makeRandomGene()
        case .upConnector:   return gUpConnector.makeRandomGene()
        default: assert(false)
        }
    }
    */
    // swiftmint:enable cyclomatic_complexity

    static func missingOverrideInSubclass() -> Never {
        preconditionFailure("Subclasses must implement this")
    }

    func mutate() -> Bool { Gene.missingOverrideInSubclass() }

    static func == (_ lhs: Gene, _ rhs: Gene) -> Bool { return lhs.idNumber == rhs.idNumber }
}

extension Gene {
    func mutate(from value: Int) -> Int {
        let i = Int(mutate(from: Double(value * 100)) / 100.0)
        return abs(i) < 1 ? i * 100 : i
    }

    func mutate(from value: Double) -> Double {
        return 0
//        return Mutator.shared.mutate(from: value)
    }
}