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

class TestSubjectFactory: SelectionTestSubjectFactory {
    var decoder = Decoder()
    var maybeMutated = String()
    var selectionControlsSet = false

    func setSelectionControls() {
        // Override this function to get the
        // global controls set up
        selectionControlsSet = true
    }

    func makeFitnessTester() -> FTFitnessTester {
        precondition(selectionControlsSet)
        return FTFitnessTester()
    }

    func makeTestSubject(parent: TSTestSubject, mutate: Bool) -> TSTestSubject? {
        precondition(selectionControlsSet)
        return makeTestSubject(parentGenome: parent.genome[...], mutate: mutate)
    }

    func makeTestSubject(parentGenome: GenomeSlice, mutate: Bool) -> TSTestSubject? {
        precondition(selectionControlsSet)

        guard decoder.setInput(to: maybeMutated[...]).decode() else { return nil }

        let brain = Translators.t.getBrain()

        return TSTestSubject(genome: maybeMutated, brain: brain)
    }

    func mutate(parentGenome: GenomeSlice) -> GenomeSlice {

        repeat {
            _ = Mutator.m.setInputGenome(parentGenome).mutate()

            maybeMutated.removeAll(keepingCapacity: true)
            maybeMutated += Mutator.m.convertToGenome()
        } while maybeMutated == parentGenome

        return maybeMutated[...]
    }
}
