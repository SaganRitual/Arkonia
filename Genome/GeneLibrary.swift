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

class gActivatorFunction: Gene, NeuronActivatorProtocol {
    var value: AFn.FunctionName
    override var description: String { return "\t\tActivator function(\(value))" }
    init(_ value: AFn.FunctionName) {
        self.value = value
        super.init(.activator)
    }

    override func copy() -> GeneLinkable { return gActivatorFunction(self.value) }

    override func mutate() -> Bool {
        let v = nok(AFn.FunctionName.allCases.firstIndex(of: value))
        let w = mutate(from: v)
        let x = w % AFn.FunctionName.allCases.count
        let newValue = AFn.FunctionName.allCases[x]

        defer { self.value = newValue }
        return newValue != self.value
    }

    override class func makeRandomGene() -> Gene {
        return gActivatorFunction(nok(AFn.FunctionName.allCases.randomElement()))
    }
}

class gBias: Gene, NeuronBiasProtocol {
    var value: Double
    override var description: String { return "\t\tBias(\(value))" }
    init(_ value: Double) {
        self.value = value
        super.init(.bias)
    }

    override func copy() -> GeneLinkable { return gBias(self.value) }
    override func mutate() -> Bool {
        let newValue = mutate(from: self.value)

        defer { self.value = newValue }
        return newValue != self.value
    }

    override class func makeRandomGene() -> Gene { return gBias(Double.random(in: -1...1)) }
}

class gIntGene: Gene {
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

    override func copy() -> GeneLinkable { return gIntGene(self.type, self.value) }

    override func mutate() -> Bool {
        let newValue = mutate(from: self.value)

        defer { self.value = newValue }
        return newValue != self.value
    }
}

class gDownConnector: gIntGene, NeuronDownConnectorProtocol {
    init(_ value: Int) { super.init(.downConnector, value) }

    override func copy() -> GeneLinkable { return gDownConnector(self.value) }

    override class func makeRandomGene() -> gDownConnector {
        return gDownConnector(Int.random(in: 0..<10))
    }
}

class gHox: gIntGene {
    init(_ value: Int) { super.init(.hox, value) }

    override func copy() -> GeneLinkable { return gHox(self.value) }

    override class func makeRandomGene() -> Gene {
        return gHox(Int.random(in: 0..<10))
    }
}

class gLock: gIntGene {
    init(_ value: Int) { super.init(.lock, value) }

    override class func makeRandomGene() -> Gene {
        return gLock(Int.random(in: 0..<10))
    }
}

class gLayer: Gene {
    override var description: String { return "\nLayer gene" }

    init() { super.init(.layer) }
    override func copy() -> GeneLinkable { return gLayer() }
    override func mutate() -> Bool { return false /* Non-value genes don't mutate */ }
    override class func makeRandomGene() -> Gene { return gLayer() }
}

class gNeuron: Gene {
    override var description: String { return "\tNeuron gene" }
    init() { super.init(.neuron) }
    override func copy() -> GeneLinkable { return gNeuron() }
    override func mutate() -> Bool { return false  /* Non-value genes don't mutate */ }
    override class func makeRandomGene() -> Gene { return gNeuron() }
}

// Doesn't do anything yet
class gPolicy: Gene {
    override var description: String { return "\t\tPolicy not implemented (yet)" }
    init() { super.init(.policy) }
    override func copy() -> GeneLinkable { return gPolicy() }
    override func mutate() -> Bool { return false /* Not sure what we'll do with policy genes yet */ }
    override class func makeRandomGene() -> Gene { return gPolicy() }
}

class gSkipAnyType: gIntGene {
    override var description: String { return "\t\tSkip (\(value) genes of any type)"  }
    init(_ value: Int) { super.init(.skipAnyType, value) }
    override func copy() -> GeneLinkable { return gSkipAnyType(self.value) }
    override func mutate() -> Bool { return false /* Haven't decided how to mutate these yet */ }
}

class gSkipOneType: gIntGene {
    let typeToSkip: GeneType

    override var description: String { return "\t\tSkip(\(value) \(typeToSkip))" }

    init(_ value: Int, typeToSkip: GeneType) {
        self.typeToSkip = typeToSkip
        super.init(.skipOneType, value)
    }

    override func copy() -> GeneLinkable {
        return gSkipOneType(self.value, typeToSkip: self.typeToSkip)
    }

    override func mutate() -> Bool { return false /* Haven't decided how to mutate these yet */ }
}

class gUpConnector: Gene, NeuronUpConnectorProtocol {
    var value: UpConnectorValue

    var weight: Double {
        get { return value.1 }
        set { value.1 = newValue }
    }

    var channel: Int {
        get { return value.0 }
        set { value.0 = newValue }
    }

    override var description: String { return "\t\tUp connector(c = \(channel), w = \(weight))" }

    init(_ value: UpConnectorValue) {
        self.value = value
        super.init(.upConnector)
    }

    override func copy() -> GeneLinkable { return gUpConnector(self.value) }

    override func mutate() -> Bool {
        let channel = mutate(from: self.channel)
        let weight = mutate(from: self.weight)
        let mutated = (channel, weight)

        defer { self.value = mutated }

        return self.value != mutated
    }

    override class func makeRandomGene() -> Gene {
        let weight = Double.random(in: -1...1)
        let channel = Int.random(in: 0..<1000)  // Any int will do; we % it later
        return gUpConnector((channel, weight))
    }
}
