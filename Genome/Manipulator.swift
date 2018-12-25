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
    static public let recognizedTokens: String = "ABFHLNRW"

    private var passthruGenome_: Genome?
    public var passthruGenome: GenomeSlice {
        if let p = passthruGenome_ { return p[...] }
        let hm = GSGoalSuite.selectionControls.howManyLayersInStarter
        passthruGenome_ = Manipulator.makePassThruGenome(hmLayers: hm)
        return passthruGenome_![...]
    }

    static public var act: Character { return "A" } // Activator -- Bool
    static public var bis: Character { return "B" } // Bias -- Stubble
    static public var fun: Character { return "F" } // Function -- string
    static public var hox: Character { return "H" } // Hox gene -- haven't worked out the type yet
    static public var lay: Character { return "L" } // Layer
    static public var neu: Character { return "N" } // Neuron
    static public var thr: Character { return "T" } // Threshold -- Stubble
    static public var ifm: Character { return "R" } // Interface marker
    static public var wgt: Character { return "W" } // Weight -- Stubble

    static public var actb: String { return "A_" } // Activator -- Bool
    static public var bisb: String { return "B_" } // Bias -- Stubble
    static public var funb: String { return "F_" } // Function -- string
    static public var hoxb: String { return "H_" } // Hox gene -- haven't worked out the type yet
    static public var layb: String { return "L_" } // Layer
    static public var neub: String { return "N_" } // Neuron
    static public var thrb: String { return "T_" } // Threshold -- Stubble
    static public var ifmb: String { return "R_" } // Interface marker
    static public var wgtb: String { return "W_" } // Weight -- Stubble

    static public var act_s: GenomeSlice { return token("A") } // Activator -- Bool
    static public var bis_s: GenomeSlice { return token("B") } // Bias -- Stubble
    static public var fun_s: GenomeSlice { return token("F") } // Function -- string
    static public var hox_s: GenomeSlice { return token("H") } // Hox gene -- haven't worked out the type yet
    static public var lay_s: GenomeSlice { return token("L") } // Layer
    static public var neu_s: GenomeSlice { return token("N") } // Neuron
    static public var ifm_s: GenomeSlice { return token("R") } // Interface marker
    static public var wgt_s: GenomeSlice { return token("W") } // Weight -- Stubble

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
        case markerGene, stringGene, doubleGene, doubletGene, doubletValue
    }

    static func splitGene(_ slice: GenomeSlice) -> [GeneComponent] {
        var splitResults = [GeneComponent]()

        for type in [GeneSplitType.markerGene, GeneSplitType.stringGene, GeneSplitType.doubleGene,
                     GeneSplitType.doubletGene, GeneSplitType.doubletValue] {

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

        case .doubleGene:
            guard let fmi = slice.firstIndex(where: { "B".contains($0) })
                else { break }

            let fsi = slice.index(fmi, offsetBy: 2)   // Point to the meat

            guard let eos = slice.lastIndex(of: ")")
                else { break }

            geneComponents.append(slice[fmi...fmi])
            geneComponents.append(slice[fsi..<eos])

        case .doubletGene:
            guard let fmi = slice.firstIndex(where: { "W".contains($0) })
                else { break }

            let bmi = slice.index(fmi, offsetBy: 4)   // Point to the base meat
            guard let eob = slice[bmi...].firstIndex(of: "]") else { break }

            let vmi = slice.index(eob, offsetBy: 3)     // Point to the value meat
            guard let eov = slice[vmi...].firstIndex(of: "]") else { break }

            let marker = slice[fmi...fmi]
            let baseline = slice[bmi..<eob]
            let value = slice[vmi..<eov]

            // See comments above under markers
            geneComponents.append(marker)
            geneComponents.append(baseline)
            geneComponents.append(value)

        case .doubletValue:
            let fmi = slice.startIndex

            let bmi = slice.index(fmi, offsetBy: 2)   // Point to the base meat
            guard let eob = slice[bmi...].firstIndex(of: "]") else { break }

            let vmi = slice.index(eob, offsetBy: 3)     // Point to the value meat
            guard let eov = slice[vmi...].firstIndex(of: "]") else { break }

            let baseline = slice[bmi..<eob]
            let value = slice[vmi..<eov]

            // See comments above under markers
            geneComponents.append(baseline)
            geneComponents.append(value)

        case .markerGene:
            guard let first = slice.firstIndex(where: { "LN".contains($0) })
                else { break }

            geneComponents.append(slice[first...first])

        case .stringGene:
            guard let fmi = slice.firstIndex(where: { "AF".contains($0) })
                else { break }

            let fsi = slice.index(fmi, offsetBy: 2)   // Point to the meat

            guard let eos = slice.lastIndex(of: ")")
                else { break }

            geneComponents.append(slice[fmi...fmi])
            geneComponents.append(slice[fsi..<eos])
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
            dag = makeOneLayer(dag, hmNeurons: GSGoalSuite.selectionControls.howManySenses)
        }

        let totalDag = makeOneLayer(dag, hmNeurons: GSGoalSuite.selectionControls.howManyMotorNeurons)

        return totalDag
    }

    static private func makeOneLayer(_ protoGenome_: Genome, hmNeurons: Int) -> Genome {
        var protoGenome = protoGenome_ + "L_"
        var bias = 1.0
        var scanRight = true
        for _ in 0..<hmNeurons {
            protoGenome += "N_A(\(scanRight))_F(identity)_W(b[\(1)]v[\(1)])_B(\(bias))_"
            bias *= -1
            scanRight = !scanRight
        }
        return protoGenome
    }

}
