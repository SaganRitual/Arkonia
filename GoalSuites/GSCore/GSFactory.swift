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
    var genomeWorkspace: String { get set }

    func getAboriginal() -> GSSubject
    func makeArkon(genome: GenomeSlice, mutate: Bool) -> GSSubject?
    func mutate(from: GenomeSlice)
}

class GSFactory: GSFactoryProtocol {
    static var aboriginalGenome: Genome?

    private var decoder: Decoder
    var genomeWorkspace = String()
    weak var suite: GSGoalSuite?

    var description: String { return "GSFactory; functioning within standard operational parameters" }

    public init() {
        decoder = Decoder()

        genomeWorkspace.reserveCapacity(1024 * 1024)
        Mutator.m.setGenomeWorkspaceOwner(self)
    }

    public func postInit(suite: GSGoalSuite) {
        self.suite = suite
        let h = suite.selectionControls.howManyLayersInStarter
        GSFactory.aboriginalGenome = Manipulator.makePassThruGenome(hmLayers: h)
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
}
