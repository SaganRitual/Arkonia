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

class Gene: CustomDebugStringConvertible, GeneLinkable {
    static var idNumber = 0

    let idNumber: Int
    let type: GeneType

    var next: GeneLinkable?
    weak var prev: GeneLinkable?

    var description: String { Gene.missingOverrideInSubclass() }
    var debugDescription: String { return description }

    static func init_(_ type: GeneType) -> (Int, GeneType) {
        defer { Gene.idNumber += 1 }
        let idNumber = Gene.idNumber
        return (idNumber, type)
    }

    init(_ type: GeneType) { (self.idNumber, self.type) = Gene.init_(type) }
    init(_ copyFrom: Gene) { Gene.missingOverrideInSubclass() }

    deinit { precondition(self.prev == nil && self.next == nil) }

    func copy() -> GeneLinkable { Gene.missingOverrideInSubclass() }
    func isMyself(_ thatGuy: GeneLinkable) -> Bool { return self === thatGuy }

    // swiftlint:disable cyclomatic_complexity

    class func makeRandomGene() -> Gene {
        let geneType = nok(GeneType.allCases.randomElement())

        switch geneType {
        case .activator:     return gActivatorFunction.makeRandomGene()
        case .bias:          return gBias.makeRandomGene()
        case .downConnector: return gDownConnector.makeRandomGene()
        case .hox:           return gHox.makeRandomGene()
        case .lock:          return gLock.makeRandomGene()
        case .layer:         return gLayer.makeRandomGene()
        case .neuron:        return gNeuron.makeRandomGene()
        case .policy:        return gPolicy.makeRandomGene()
        case .skipAnyType:   return gSkipAnyType.makeRandomGene()
        case .skipOneType:   return gSkipOneType.makeRandomGene()
        case .upConnector:   return gUpConnector.makeRandomGene()
        }
    }

    // swiftlint:enable cyclomatic_complexity

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
        return ArkonCentralDark.mutator.mutate(from: value)
    }
}
