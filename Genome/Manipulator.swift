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

class Manipulator {
    private var passthruGenome_: Genome?
    public var passthruGenome: GenomeSlice {
        if let p = passthruGenome_ { return p[...] }
        let hm = GSGoalSuite.selectionControls.howManyLayersInStarter
        passthruGenome_ = Manipulator.makePassThruGenome(hmLayers: hm)
        return passthruGenome_![...]
    }

    static public let recognizedTokens = "ABDHIKLNPW"

    static public var gAct: Character { return "A" } // Activator -- AFn.FunctionName
    static public var gBis: Character { return "B" } // Bias -- Double
    static public var gDwn: Character { return "D" } // Down -- Void
    static public var gHox: Character { return "H" } // Hox gene -- (cGenesToCopy: Int, cCopiesToMake: Int)
    static public var gInt: Character { return "I" } // Multi-purpose int -- Int
    static public var gLok: Character { return "K" } // Lock -- cGenesToLock: Int
    static public var gLay: Character { return "L" } // Layer -- Void
    static public var gNeu: Character { return "N" } // Neuron -- Void
    static public var gPol: Character { return "P" } // Policy -- PolicyName (or something)
    static public var gWgt: Character { return "W" } // Weight -- Double

    static public var sAct: GenomeSlice { return token("A") } // Activator -- AFn.FunctionName
    static public var sBis: GenomeSlice { return token("B") } // Bias -- Double
    static public var sDwn: GenomeSlice { return token("D") } // Down -- Void
    static public var sHox: GenomeSlice { return token("H") } // Hox gene -- (cGenesToCopy: Int, cCopiesToMake: Int)
    static public var sInt: GenomeSlice { return token("I") } // Multi-purpose int -- Int
    static public var sLok: GenomeSlice { return token("K") } // Lock -- cGenesToLock: Int
    static public var sLay: GenomeSlice { return token("L") } // Layer -- Void
    static public var sNeu: GenomeSlice { return token("N") } // Neuron -- Void
    static public var sPol: GenomeSlice { return token("P") } // Policy -- PolicyName (or something)
    static public var sWgt: GenomeSlice { return token("W") } // Weight -- Double

    static public func token(_ character: Character) -> GenomeSlice {
        let t = Manipulator.recognizedTokens
        guard let start = t.firstIndex(of: character) else {
            preconditionFailure()
        }

        return t[start...start]
    }
}

// swiftlint:disable nesting

extension Manipulator {

    typealias Gene = Substring
    typealias GeneComponent = Substring
    struct GenomeIterator: IteratorProtocol, Sequence {
        typealias Element = Gene

        let genome: GenomeSlice
        let recognizedTokens: Substring
        var currentIndex: Gene.Index

        init(_ genome: GenomeSlice) {
            self.genome = genome
            self.currentIndex = genome.startIndex
            self.recognizedTokens = Manipulator.recognizedTokens[...]
        }

        public mutating func next() -> Element? {
            guard let c = genome[currentIndex...].firstIndex(where: {
                recognizedTokens.contains($0)
            }) else { return nil }

            guard let end = genome[c...].firstIndex(of: "_") else { preconditionFailure() }

            defer { currentIndex = genome.index(after: end) }
            return genome[c..<end]
        }
    }

}
// swiftlint:enable nesting

extension Manipulator {
    enum GeneSplitType {
        case numberGene, stringGene, voidGene
    }

    static func splitGene(_ slice: GenomeSlice) -> [GeneComponent] {
        var splitResults = [GeneComponent]()

        for type in [GeneSplitType.numberGene,
                     GeneSplitType.stringGene,
                     GeneSplitType.voidGene] {

            splitResults = splitGene(slice, type)

            if !splitResults.isEmpty { return splitResults }
        }

        preconditionFailure("No match in '\(slice)'")
    }

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length

    static func splitGene(_ slice: GenomeSlice, _ splitType: GeneSplitType) -> [GeneComponent] {
        var geneComponents = [GeneComponent]()

        switch splitType {

        case .numberGene:
            guard let fmi = slice.firstIndex(where: { "BIW".contains($0) })
                else { break }

            let fsi = slice.index(fmi, offsetBy: 2)   // Point to the meat

            guard let eos = slice.lastIndex(of: ")")
                else { break }

            geneComponents.append(slice[fmi...fmi])
            geneComponents.append(slice[fsi..<eos])

        case .stringGene:
            guard let fmi = slice.firstIndex(where: { "A".contains($0) })
                else { break }

            let fsi = slice.index(fmi, offsetBy: 2)   // Point to the meat

            guard let eos = slice.lastIndex(of: ")")
                else { break }

            geneComponents.append(slice[fmi...fmi])
            geneComponents.append(slice[fsi..<eos])

        case .voidGene:
            guard let first = slice.firstIndex(where: { "DLN".contains($0) })
                else { break }

            geneComponents.append(slice[first...first])
        }

        return geneComponents
    }
    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_body_length
}

extension Manipulator {

    static public func makePassThruGenome(hmLayers: Int) -> Genome {
        var dag = Genome()
        for _ in 0..<hmLayers {
            dag = makeOneLayer(dag, cNeurons: GSGoalSuite.selectionControls.howManySenses)
        }

        let totalDag = makeOneLayer(dag, cNeurons: GSGoalSuite.selectionControls.howManyMotorNeurons)

        return totalDag
    }

    static private func makeOneLayer(_ protoGenome_: Genome, cNeurons: Int) -> Genome {
        var protoGenome = protoGenome_ + "L_"
        for c in 0..<cNeurons {
            protoGenome += "N_A(\(AFn.FunctionName.boundidentity.rawValue))_I(\(c))_W(1.0)_B(0.0)_"

            for d in 0..<GSGoalSuite.selectionControls.howManyMotorNeurons {
                protoGenome += "I(\(d))_D_"
            }
        }
        return protoGenome
    }

}
