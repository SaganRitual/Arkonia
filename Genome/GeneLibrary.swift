import Foundation

protocol GeneProtocol {
    var core: GeneCore { get }

    init(_ core: GeneCore)

    func mutated(from: GeneCore) -> GeneCore
}

extension GeneProtocol {
    init(_ core: GeneCore) {
        switch core {
        case let .double(d, m):      self.init(GeneCore.double(d, m))
        case let .int(i, t, m):      self.init(GeneCore.int(i, t, m))
        case let .activator(v, m):   self.init(GeneCore.activator(v, m))
        case let .upConnector(u, m): self.init(GeneCore.upConnector(u, m))
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
        let randomFunctionName = hardBind(AFn.FunctionName.allCases.randomElement())
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

extension Double {
    static func random(in range: Range<Double>, excluding middle: Double) -> Double {
        let sign = Bool.random() ? 1.0 : -1.0
        let exclude = middle / 2.0
        return sign * (abs(Double.random(in: range)) / 2) + exclude
    }
}

struct gUpConnector: GeneProtocol {

    // To prevent something like dividing by .0000001. If they're going
    // to grow exponentially, let's limit it to a certain factor each time.
    static let maxAmplificationPerMutation = 1.75

    var core: GeneCore

    init(_ connector: UpConnector, isMutatedCopy: Bool = false) {
        core = GeneCore.upConnector(connector, isMutatedCopy)
    }

    static func makeRandomGene() -> GeneProtocol {
        let maxAPM = maxAmplificationPerMutation
        let amplification = Double.random(in: -1.0..<1.0, excluding: 2 * 1 / maxAPM)
        let amplificationMode = UpConnectorAmplifier.AmplificationMode.increase
        let channel_ = Int.random(in: 0..<GeneCore.upConnectorChannelTopOfRange)
        let weight_ = Double.random(in: -1...1)

        let amplifier = UpConnectorAmplifier(
            amplificationMode: amplificationMode, multiplier: amplification
        )

        let channel = UpConnectorChannel(
            channel: channel_, topOfRange: GeneCore.upConnectorChannelTopOfRange
        )

        let weight = UpConnectorWeight(weight: weight_)

        let upConnector = UpConnector(channel, weight, amplifier)
        return gUpConnector(upConnector, isMutatedCopy: false)
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
