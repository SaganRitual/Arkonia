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

class TSMultiplier: TSTestSubject {
    override init(with genome: Genome, brain: BrainStem?, fitnessTester: TestSubjectFitnessTester) {
        super.init(with: genome, brain: brain, fitnessTester: fitnessTester)

        setSelectionControls()
    }

    func setSelectionControls() {
        selectionControls.howManySenses = 2
        selectionControls.howManyMotorNeurons = 1
    }
}

class TSMultiplierFactory: TestSubjectFactory {
    override func makeTestSubject(genome: Genome, mutate: Bool) -> TSMultiplier {
        var maybeMutated = genome
        if mutate {
            _ = Mutator.m.setInputGenome(genome).mutate()
            maybeMutated = Mutator.m.convertToGenome()
        }

        try decoder.setInput(to: maybeMutated).decode()
        let brain = Translators.t.getBrain()

        return TSMultiplier(with: maybeMutated, brain: brain, fitnessTester: fitnessTester)
    }
}

#if false
class FTMultiplier: TestSubjectFitnessTester {
    var charactersMatched = 0
    override func setFitnessScore(for testSubject: TSTestSubject, outputs: [Double]?) {
        guard let outputs = outputs else { return }

        var scoreForTheseOutputs = 0.0

        let scorer = Scorer(zName, outputs: outputs)
        scoreForTheseOutputs += scorer.getScore()

        if scoreForTheseOutputs == 0 {
            charactersMatched += 1
            scoreForTheseOutputs = Double(abs(zName.count - charactersMatched))
        }

        testSubject.setFitnessScore(scoreForTheseOutputs)
    }
}
#endif
