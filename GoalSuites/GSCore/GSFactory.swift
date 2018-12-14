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

protocol GSFactoryProtocol: class, CustomStringConvertible {
    var decoder: Decoder { get }
    var genomeWorkspace: String { get set }

    func getAboriginal() -> GSSubject
    func makeArkon(genome: GenomeSlice, mutate: Bool) -> GSSubject?
    func mutate(from: GenomeSlice)
}

class GSFactory: GSFactoryProtocol {
    static private var aboriginalGenome: Genome?
    static public let recognizedTokens: String = "ABFHLNRW"

    internal var decoder: Decoder
    var genomeWorkspace = String()

    var description: String { return "GSFactory; functioning within standard operational parameters" }

    public init() {
        decoder = Decoder()

        genomeWorkspace.reserveCapacity(1024 * 1024)

        let h = GSGoalSuite.selectionControls.howManyLayersInStarter
        GSFactory.aboriginalGenome = GSFactory.makePassThruGenome(hmLayers: h)

        Mutator.m.setGenomeWorkspaceOwner(self)
    }

    public func makeArkon(genome: GenomeSlice, mutate: Bool = true) -> GSSubject? {
        guard let brain = makeBrain(genome: genome, mutate: mutate) else { return nil }

        return GSSubject(genome: genomeWorkspace[...], brain: brain)
    }

    func makeBrain(genome: GenomeSlice, mutate: Bool) -> Translators.Brain? {
        if mutate { self.mutate(from: genome)  }
        else { genomeWorkspace.append(String(genome))}

        guard decoder.setInput(to: genomeWorkspace[...]).decode() else { return nil }
        return Translators.t.getBrain()
    }

    public func mutate(from reference: GenomeSlice) {
        repeat {
            Mutator.m.setInputGenome(reference).mutate()
            Mutator.m.convertToGenome()
        } while genomeWorkspace.elementsEqual(reference)
    }
}

extension GSFactory {
    public func getAboriginal() -> GSSubject {
        let ag = GSFactory.aboriginalGenome![...]

        guard let aboriginal = makeArkon(genome: ag, mutate: false)
            else { preconditionFailure("Aboriginal should survive birth") }

        return aboriginal
    }

    static private func makePassThruGenome(hmLayers: Int) -> Genome {
        var dag = Genome()
        for _ in 0..<hmLayers {
            dag = makeOneLayer(dag, hmNeurons: GSGoalSuite.selectionControls.howManySenses)
        }

        dag = makeOneLayer(dag, hmNeurons: GSGoalSuite.selectionControls.howManyMotorNeurons)
        return dag
    }

    static private func makeOneLayer(_ protoGenome_: Genome, hmNeurons: Int) -> Genome {
        var protoGenome = protoGenome_ + "L_"

        for portNumber in 0..<hmNeurons {
            protoGenome += "N_"
            for _ in 0..<portNumber { protoGenome += "A(false)_" }

            protoGenome += "A(true)_F(linear)_W(b[\(1)]v[\(1)])_B(0)_"
        }

        return protoGenome
    }
}
