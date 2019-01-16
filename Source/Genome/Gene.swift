//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//

import Foundation

enum GeneType {
    /// Activator function
    case activator
    /// Bias to add to output signal
    case bias
    /// Special connection to the motor layer
    case downConnector
    /// Segment multiplier, as in real life
    case hox
    /// Experimental segment wrapper, causes the genes to be seen as
    /// a single gene by the Mutator, such that they never get scrambled
    /// internally, but move together as a unit
    case lock
    /// Container for neurons
    case layer
    /// For testing; the payload is an Int
    case mockGene
    /// In person
    case neuron
    /// Experimental, set custom behavior or something, I don't know. I'm thinking
    /// something like a "no more than five layers" policy, or something.
    case policy
    /// The usual way neurons connect
    case upConnector
}

class Gene {
    static var idNumber = 0

    let idNumber: Int
    let type: GeneType

    var next: Gene?
    weak var prev: Gene?

    var description: String { return "If you can read this, something has gone haywire." }

    static func init_(_ type: GeneType) -> (Int, GeneType) {
        defer { Gene.idNumber += 1 }
        let idNumber = Gene.idNumber
        return (idNumber, type)
    }

    init(_ type: GeneType) { (self.idNumber, self.type) = Gene.init_(type) }
    init(_ copyFrom: Gene) { preconditionFailure("Subclasses must implement this") }

    func copy() -> Gene { preconditionFailure("Subclasses must implement this") }

    static func == (_ lhs: Gene, _ rhs: Gene) -> Bool { return lhs.idNumber == rhs.idNumber }
}

class gActivatorFunction: Gene {
    let value: AFn.FunctionName
    override var description: String { return "Activator function" }
    init(_ value: AFn.FunctionName) {
        self.value = value
        super.init(.activator)
    }

    override func copy() -> Gene { return gActivatorFunction(self.value) }
}

class gBias: Gene {
    let value: Double
    override var description: String { return "Bias" }
    init(_ value: Double) {
        self.value = value
        super.init(.bias)
    }

    override func copy() -> Gene { return gBias(self.value) }
}

class gIntGene: Gene {
    let value: Int

    override var description: String {
        var d = ""
        switch self.type {
        case .downConnector: d = "Down connector"
        case .hox: d = "Hox"
        case .lock: d = "Lock"
        default: preconditionFailure()
        }

        return "\(d)(\(value))"
    }

    init(_ type: GeneType, _ value: Int) {
        self.value = value
        super.init(type)
    }

    override func copy() -> Gene { return gIntGene(self.type, self.value) }
}

class gDownConnector: gIntGene { init(_ value: Int) { super.init(.downConnector, value) } }
class gHox: gIntGene { init(_ value: Int) { super.init(.hox, value) } }
class gLock: gIntGene { init(_ value: Int) { super.init(.lock, value) } }

class gLayer: Gene {
    init() { super.init(.layer) }
    override func copy() -> Gene { return gLayer() }
}

class gMockGene: Gene, CustomDebugStringConvertible {
    let value: Int
    override var description: String { return debugDescription }
    var debugDescription: String { return "Mock gene: value = \(value)" }
    init(_ value: Int) { self.value = value; super.init(.mockGene) }
    override func copy() -> Gene { return gMockGene(value) }
}

class gNeuron: Gene {
    init() { super.init(.neuron) }
    override func copy() -> Gene { return gNeuron() }
}

// Doesn't do anything yet
class gPolicy: Gene { init() {
    super.init(.policy) }
    override func copy() -> Gene { return gPolicy() }
}

class gUpConnector: Gene {
    let channel: Int
    let weight: Double

    override var description: String { return "Up connector" }

    init(_ value: (Double, Int)) {
        (weight, channel) = value
        super.init(.upConnector)
    }

    override func copy() -> Gene { return gUpConnector((self.weight, self.channel)) }
}
