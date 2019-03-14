import Foundation

protocol GeneProtocol {
    var core: GeneCore { get }

    init(_ core: GeneCore)

    func mutated(from: GeneCore) -> GeneCore
}

extension GeneProtocol {
    init(_ core: GeneCore) {
        switch core {
        case let .double(d, m):            self.init(GeneCore.double(d, m))
        case let .int(i, t, m):            self.init(GeneCore.int(i, t, m))
        case let .activator(v, m):         self.init(GeneCore.activator(v, m))
        case let .upConnector(c, t, w, m): self.init(GeneCore.upConnector(c, t, w, m))
        default: preconditionFailure()
        }
    }

    func mutated(from: GeneCore) -> GeneCore { return GeneCore.mutated(from: core) }
}

struct gActivatorFunction: GeneProtocol {
    var core: GeneCore

    init(_ functionName: AFn.FunctionName, isMutatedCopy: Bool = false) {
        core = GeneCore.activator(functionName, isMutatedCopy)
    }

    static func makeRandomGene() -> GeneProtocol {
        let randomFunctionName = nok(AFn.FunctionName.allCases.randomElement())
        return gActivatorFunction(randomFunctionName)
    }
}

struct gBias: GeneProtocol {
    var core: GeneCore

    init(_ bias: Double, isMutatedCopy: Bool = false) {
        core = GeneCore.double(bias, isMutatedCopy)
    }

    static func makeRandomGene() -> GeneProtocol {
        let randomDouble = Double.random(in: -1...1)
        return gBias(randomDouble)
    }
}

struct gDownConnector: GeneProtocol {
    var core: GeneCore

    init(_ channel: Int, isMutatedCopy: Bool = false) {
        core = GeneCore.int(channel, GeneCore.downConnectorTopOfRange, isMutatedCopy)
    }

    static func makeRandomGene() -> GeneProtocol {
        let topOfRange = GeneCore.downConnectorTopOfRange
        let newChannel = Int.random(in: 0..<topOfRange)
        return gDownConnector(newChannel)
    }
}

struct gHox: GeneProtocol {
    var core: GeneCore

    init(_ count: Int, isMutatedCopy: Bool = false) {
        core = GeneCore.int(count, GeneCore.hoxTopOfRange, isMutatedCopy)
    }

    static func makeRandomGene() -> GeneProtocol {
        let topOfRange = GeneCore.hoxTopOfRange
        let newChannel = Int.random(in: 0..<topOfRange)
        return gHox(newChannel)
    }
}

struct gLock: GeneProtocol {
    var core: GeneCore

    init(_ count: Int, isMutatedCopy: Bool = false) {
        core = GeneCore.int(count, GeneCore.lockTopOfRange, isMutatedCopy)
    }

    static func makeRandomGene() -> GeneProtocol {
        let topOfRange = GeneCore.lockTopOfRange
        let newChannel = Int.random(in: 0..<topOfRange)
        return gLock(newChannel)
    }
}

struct gLayer: GeneProtocol {
    var core: GeneCore

    init() { core = GeneCore.empty }

    func mutated() -> gLayer { return gLayer() }
    static func makeRandomGene() -> GeneProtocol { return gLayer() }
}

struct gNeuron: GeneProtocol {
    var core: GeneCore

    init() { core = GeneCore.empty }

    func mutated() -> gNeuron { return gNeuron() }
    static func makeRandomGene() -> GeneProtocol { return gNeuron() }
}

struct gUpConnector: GeneProtocol {
    var core: GeneCore

    init(_ connector: UpConnectorValue, isMutatedCopy: Bool = false) {
        core = GeneCore.upConnector(
            connector.channel,
            GeneCore.upConnectorChannelTopOfRange,
            connector.weight,
            isMutatedCopy
        )
    }

    static func makeRandomGene() -> GeneProtocol {
        let weight = Double.random(in: -1...1)
        let channel = Int.random(in: 0..<GeneCore.upConnectorChannelTopOfRange)
        return nok(gUpConnector((channel, weight)))
    }
}
/*
// Doesn't do anything yet
struct gPolicy: Chromosome {
    let isMutatedCopy = false
    var rawData: Int { return 0 }

    init(_ notUsed: Int, isMutatedCopy: Bool = false) { }
    func mutated() -> gPolicy { return gPolicy(0) }
    static func makeRandomGene<T: Chromosome>() -> T { return nok(gPolicy(0) as? T) }
}

struct gSkipAnyType: Chromosome {
    let isMutatedCopy = false
    var rawData: Int { return 0 }

    init(_ notUsed: Int, isMutatedCopy: Bool = false) { }
    func mutated() -> gSkipAnyType { return gSkipAnyType(0) }
    static func makeRandomGene<T: Chromosome>() -> T { return nok(gSkipAnyType(0) as? T) }
}

struct gSkipOneType: Chromosome {
    let isMutatedCopy = false
    var rawData: Int { return 0 }

    init(_ notUsed: Int, isMutatedCopy: Bool = false) { }
    func mutated() -> gSkipOneType { return gSkipOneType(0) }
    static func makeRandomGene<T: Chromosome>() -> T { return nok(gSkipOneType(0) as? T) }
}
*/
/*
 struct gIntGene: Chromosome {
 var value: Int

 override var description: String {
 var d = ""
 switch self.type {
 case .downConnector: d = "\t\tDown connector"
 case .hox: d = "\t\tHox"
 case .lock: d = "\t\tLock"
 default: preconditionFailure()
 }

 return "\(d)(\(value))"
 }

 init(_ type: GeneType, _ value: Int) {
 self.value = value
 super.init(type)
 }

 override func copy() -> Gene { return gIntGene(self.type, self.value) }

 override func mutated() -> Bool {
 let newValue = mutated(from: self.value)

 defer { self.value = newValue }
 return newValue != self.value
 }
 }
 */
//struct AnyChromosome<ChromosomeType>: Chromosome {
//    let isMutatedCopy: Bool
//    let rawData: Int
//
//    init<U: Chromosome>(_ pokemon: U, isMutatedCopy: Bool = false) where
//        U.ChromosomeType == ChromosomeType, U.RawDataType == RawDataType
//    {
//        self.isMutatedCopy = isMutatedCopy
//        self.rawData = pokemon.rawData
//    }
//
//    func mutated() -> ChromosomeType { preconditionFailure() }
//    static func makeRandomGene() -> ChromosomeType { preconditionFailure() }
//}
