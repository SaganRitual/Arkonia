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

class GSFactory {
    static var aboriginalGenome: Genome?

    internal var decoder = Decoder()
    var genomeWorkspace = String()
    weak var suite: GSGoalSuite?

    var description: String { return "GSFactory; functioning within standard operational parameters" }

    public init() {
        genomeWorkspace.reserveCapacity(1024 * 1024)
        ArkonCentral.mut.setGenomeWorkspaceOwner(self)
    }

    public func getAboriginal() -> GSSubject {
        let ag = GSFactory.aboriginalGenome![...]

        guard let aboriginal = makeArkon(genome: ag, mutate: false)
            else { preconditionFailure("Aboriginal should survive birth") }

        return aboriginal
    }

    func makeArkon(genome: GenomeSlice, mutate: Bool) -> GSSubject? {
        preconditionFailure("Must be implemented in subclass")
    }

    func makeNet(genome: GenomeSlice, mutate: Bool) -> TNet? {
        if mutate { self.mutate(from: genome) }
        else { genomeWorkspace.append(String(genome)) }

        return decoder.setInput(to: genomeWorkspace[...]).decode()
    }

    public func mutate(from reference: GenomeSlice) {
        repeat {
            ArkonCentral.mut.setInputGenome(reference).mutate()
            ArkonCentral.mut.convertToGenome()
        } while genomeWorkspace.elementsEqual(reference)
    }

    public func postInit(suite: GSGoalSuite) {
        self.suite = suite
        let h = ArkonCentral.sel.cLayersInStarter
        GSFactory.aboriginalGenome = Manipulator.makePassThruGenome(cLayers: h)
    }
}
