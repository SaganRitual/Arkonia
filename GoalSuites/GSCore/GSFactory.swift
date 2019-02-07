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

    internal var decoder = FDecoder()
    internal var mutator = Mutator()
    weak var suite: GSGoalSuite?

    var description: String { return "GSFactory; functioning within standard operational parameters" }

    public func getAboriginal() -> GSSubject {
        let genome = GSFactory.aboriginalGenome !! { preconditionFailure() }

        let aboriginal = makeArkon(genome: genome, mutate: false) !!
            { preconditionFailure("Aboriginal should survive birth") }

        return aboriginal
    }

    func makeArkon(genome: Genome, mutate: Bool) -> GSSubject? {
        preconditionFailure("Must be implemented in subclass")
    }

    func makeNet(genome: Genome, mutate: Bool) -> (Genome, FNet?) {
        let m = nok(ArkonCentralDark.mutator as? Mutator)
        var newGenome = genome.copy()
        if mutate { newGenome = nok(m.setInputGenome(newGenome).mutate() as? Segment) }
        let d = decoder.setInputGenome(newGenome)
        let e = d.decode()
        return (newGenome, e as? FNet)
    }

    public func postInit(suite: GSGoalSuite) {
        self.suite = suite
        GSFactory.aboriginalGenome = Assembler.makePassThruGenome()
    }
}
