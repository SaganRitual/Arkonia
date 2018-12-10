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
    var howManyMotorNeurons = 20
    var howManyGenerations = 30000
    var howManyGenes = 200
    var howManyLayersInStarter = 5
    var howManySubjectsPerGeneration = 100
    var theFishNumber = 0
    var dudlinessThreshold = 1
    var stackTieScoresLimit = 2
    var maxKeepersPerGeneration = 2
    var hmSpawnAttempts = 2
}

var selectionControls: SelectionControls!

class Statics {
    static let s = Statics()

    private let aboriginalGenome: Genome

    public let recognizedTokens: String = "ABFHLNRW"

    init() {
        aboriginalGenome = Statics.makeAboriginalGenome(selectionControls!.howManyLayersInStarter)
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
        for _ in 0..<hmLayers { dag = makeOneLayer(dag, hmNeurons: selectionControls.howManySenses) }
        dag = makeOneLayer(dag, hmNeurons: selectionControls.howManyMotorNeurons)
        return dag
    }

    public static func makePromisingAboriginal(factory: TestSubjectFactory) -> TSTestSubject? {
        let p = Statics.s.getAboriginalGenome()
        return factory.makeTestSubject(parentGenome: p, mutate: false)
    }

    private static func makeOneLayer(_ protoGenome_: Genome, hmNeurons: Int) -> Genome {
        var protoGenome = protoGenome_ + "L_"

        for portNumber in 0..<hmNeurons {
            protoGenome += "N_"
            for _ in 0..<portNumber { protoGenome += "A(false)_" }

            protoGenome += "A(true)_F(linear)_W(b[\(1)]v[\(1)])_B(b[\(0)]v[\(0)])_"
        }

        return protoGenome
    }
}
