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
    static public let recognizedTokens = "ABDHKLNPU"

    static public var gAct: Character { return "A" } // Activator -- AFn.FunctionName
    static public var gBis: Character { return "B" } // Bias -- Double
    static public var gDnc: Character { return "D" } // Down connector -- Int
    static public var gHox: Character { return "H" } // Hox gene -- (cGenesToCopy: Int, cCopiesToMake: Int)
    static public var gLok: Character { return "K" } // Lock -- cGenesToLock: Int
    static public var gLay: Character { return "L" } // Layer -- Void
    static public var gNeu: Character { return "N" } // Neuron -- Void
    static public var gPol: Character { return "P" } // Policy -- PolicyName (or something)
    static public var gUpc: Character { return "U" } // Up connector -- weight: Double, line: Int

    static public var sAct: GenomeSlice { return token("A") } // Activator -- AFn.FunctionName
    static public var sBis: GenomeSlice { return token("B") } // Bias -- Double
    static public var sDnc: GenomeSlice { return token("D") } // Down connector -- Int
    static public var sHox: GenomeSlice { return token("H") } // Hox gene -- (cGenesToCopy: Int, cCopiesToMake: Int)
    static public var sLok: GenomeSlice { return token("K") } // Lock -- cGenesToLock: Int
    static public var sLay: GenomeSlice { return token("L") } // Layer -- Void
    static public var sNeu: GenomeSlice { return token("N") } // Neuron -- Void
    static public var sPol: GenomeSlice { return token("P") } // Policy -- PolicyName (or something)
    static public var sUpc: GenomeSlice { return token("U") } // Up connector -- weight: Double, line: Int

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
        case numberGene, stringGene, upConnectorGene, upConnectorValue, voidGene
    }

    static func splitGene(_ slice: GenomeSlice) -> [GeneComponent] {
        var splitResults = [GeneComponent]()

        for type in [GeneSplitType.numberGene,
                     GeneSplitType.stringGene,
                     GeneSplitType.upConnectorGene,
                     GeneSplitType.upConnectorValue,
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
            guard let fmi = slice.firstIndex(where: { "BD".contains($0) })
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

        case .upConnectorGene:
            guard let fmi = slice.firstIndex(where: { "U".contains($0) })
                else { break }

            let bmi = slice.index(fmi, offsetBy: 4)   // Point to the base meat
            guard let eob = slice[bmi...].firstIndex(of: "]") else { break }

            let vmi = slice.index(eob, offsetBy: 3)     // Point to the value meat
            guard let eov = slice[vmi...].firstIndex(of: "]") else { break }

            let marker = slice[fmi...fmi]
            let weight = slice[bmi..<eob]
            let channel = slice[vmi..<eov]

            geneComponents.append(marker)
            geneComponents.append(weight)
            geneComponents.append(channel)

        case .upConnectorValue:
            guard let fmi = slice.firstIndex(where: { "w".contains($0) })
                else { break }

            let bmi = slice.index(fmi, offsetBy: 2)   // Point to the base meat
            guard let eob = slice[bmi...].firstIndex(of: "]") else { break }

            let vmi = slice.index(eob, offsetBy: 3)     // Point to the value meat
            guard let eov = slice[vmi...].firstIndex(of: "]") else { break }

            let weight = slice[bmi..<eob]
            let channel = slice[vmi..<eov]

            // See comments above under markers
            geneComponents.append(weight)
            geneComponents.append(channel)

        case .voidGene:
            guard let first = slice.firstIndex(where: { "LN".contains($0) })
                else { break }

            geneComponents.append(slice[first...first])
        }

        return geneComponents
    }
    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_body_length
}

extension Manipulator {

    static public func makePassThruGenome(cLayers: Int) -> Genome {
        var dag = Genome()
        for _ in 0..<cLayers - 1 {
            dag = makeOneLayer(dag, cNeurons: ArkonCentral.sel.cSenseNeurons)
        }

        dag = makeLastHiddenLayer(
            dag, cNeurons: ArkonCentral.sel.cSenseNeurons, oNeurons: ArkonCentral.sel.cMotorNeurons
        )

        return dag
    }

    static func baseNeuronSnippet(_ channel: Int) -> Genome {
        return "N_A(\(AFn.FunctionName.boundidentity.rawValue))_U(w[1.0]c[\(channel)])_B(0.0)_"
    }

    static private func makeLastHiddenLayer(_ protoGenome_: Genome, cNeurons: Int, oNeurons: Int) -> Genome {
        var protoGenome = protoGenome_ + "L_"

        var downsPerNeuron = oNeurons / cNeurons
        if downsPerNeuron == 0 { downsPerNeuron = cNeurons / oNeurons }

        var remainder = oNeurons * cNeurons - downsPerNeuron

        var channel = (100 / cNeurons) + cNeurons
        for c in 0..<cNeurons {
            protoGenome += baseNeuronSnippet(c)

            let r = remainder > 0 ? 1 : 0
            remainder -= r  // Stops at zero, because I'm so clever

            for _ in 0..<(downsPerNeuron + r) {
                protoGenome += "D(\(channel))_"
                channel += 1
            }
        }

        return protoGenome
    }

    static private func makeOneLayer(cNeurons: Int) -> Genome {
        var protoGenome = Genome(gLayer())
        for c in 0..<cNeurons { protoGenome += baseNeuronSnippet(c) }
        return protoGenome
    }

}
