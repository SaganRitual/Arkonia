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

struct SelectionControls {
    var howManySenses = 5
    var howManyMotorNeurons = "Zoe Bishop".count
    var howManyGenerations = 30000
    var howManyGenes = 200
    var howManySubjectsPerGeneration = 200
    var theFishNumber = 0
    var dudlinessThreshold = 1
    var stackTieScoresLimit = 5
    var keepersPerGenerationLimit = 3
}

var selectionControls = SelectionControls()

class Statics {
    static let s = Statics()

    private let sensesInterface_: Genome!
    private let outputsInterface_: Genome!
    private let aboriginalGenome: Genome

    public let sensesInterface: GenomeSlice
    public let outputsInterface: GenomeSlice
    public let recognizedTokens: String = "ABFHLNRW"

    init() {
        sensesInterface_ = Statics.makeSensesInterface()
        outputsInterface_ = Statics.makeOutputsInterface()
        sensesInterface = sensesInterface_[...]
        outputsInterface = outputsInterface_[...]
        aboriginalGenome = Statics.makeAboriginalGenome(3)
    }

    var act_s: GenomeSlice { return token("A") } // Activator -- Bool
    var bis_s: GenomeSlice { return token("B") } // Bias -- Stubble
    var fun_s: GenomeSlice { return token("F") } // Function -- string
    var hox_s: GenomeSlice { return token("H") } // Hox gene -- haven't worked out the type yet
    var lay_s: GenomeSlice { return token("L") } // Layer
    var neu_s: GenomeSlice { return token("N") } // Neuron
    var ifm_s: GenomeSlice { return token("R") } // Interface marker
    var wgt_s: GenomeSlice { return token("W") } // Weight -- Stubble

    public func token(_ character: Character) -> GenomeSlice {
        guard let start = recognizedTokens.firstIndex(of: character) else {
            preconditionFailure()
        }

        return recognizedTokens[start...start]
    }

    public func getAboriginalGenome() -> GenomeSlice {
        return Statics.s.aboriginalGenome[...]
    }

    private static func makeAboriginalGenome(_ hmLayers: Int) -> Genome {
        var dag = Genome()
        for _ in 0..<hmLayers { dag = makeOneLayer(dag, ctNeurons: 5) }
        return dag
    }

    private static func makeSensesInterface() -> Genome {
        var g = Genome(); g += layb

        for portNumber in 0..<selectionControls.howManySenses {
            g += neub
            for _ in 0..<portNumber { g += "A(false)_" }

            g += "A(true)_W(b[1.0]v[1.0])_B(b[0.0]v[0.0])_"
        }

        g += ifmb; return g
    }

    public static func makePromisingAboriginal(factory: TestSubjectFactory) -> TSTestSubject? {
        let p = Statics.s.getAboriginalGenome() + Statics.s.outputsInterface
        return factory.makeTestSubject(parentGenome: p, mutate: false)
    }

    private static func makeOneLayer(_ protoGenome_: Genome, ctNeurons: Int) -> Genome {
        var protoGenome = protoGenome_ + "L_"

        for portNumber in 0..<ctNeurons {
            protoGenome += "N_"
            for _ in 0..<portNumber { protoGenome += "A(false)_" }

            #if PROMISING_GENOME_FOR_ZOE
            let randomBias = Double.random(in: -1...1).sTruncate()
            let randomWeight = Double.random(in: -1...1).sTruncate()
            protoGenome += "A(true)_F(linear)_W(b[\(randomWeight)]v[\(randomWeight)])_B(b[\(randomBias)]v[\(randomBias)])_"
            #else
            protoGenome += "A(true)_F(linear)_W(b[\(1)]v[\(1)])_B(b[\(0)]v[\(0)])_"
            #endif
        }

        return protoGenome
    }

    private static func makeOutputsInterface() -> Genome {
        var g = Genome(); g += layb
        for whichNeuron in 0..<selectionControls.howManyMotorNeurons {
            g += neub
            for _ in 0..<whichNeuron { g += "A(false)_" }
            g += "A(true)_W(b[1.0]v[1.0])_B(b[0.0]v[0.0])_"
        }
        return g
    }
}
