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
//import CoreGraphics // For the math functions

class TSLearnZoeName: TSTestSubject {
    var attemptedZName = String()
}

class TSZoeFactory: TestSubjectFactory {
    override func makeFitnessTester() -> FTFitnessTester {
        return FTLearnZoeName()
    }

    override func makeTestSubject(parent: TSTestSubject, mutate: Bool) -> TSTestSubject? {
        return makeTestSubject(parentGenome: parent.genome[...], mutate: mutate)
    }

    override func makeTestSubject(parentGenome: GenomeSlice, mutate: Bool) -> TSTestSubject? {
        let mutated = mutate ? super.mutate(parentGenome: parentGenome) : parentGenome

        guard decoder.setInput(to: mutated).decode() else { return nil }

        let brain = Translators.t.getBrain()
        return TSLearnZoeName(genome: String(mutated), brain: brain)
    }

    override func setSelectionControls() {
        super.setSelectionControls()    // Setup defaults

        selectionControls.howManySenses = 5
        selectionControls.howManyLayersInStarter = 5
        selectionControls.howManyMotorNeurons = "Zoe Bishop".count
    }
}

class FTLearnZoeName: FTFitnessTester {
    var charactersMatched = 0

    override func doScoringStuff(_ ts: TSTestSubject, _ outputs: [Double?]) -> Double {
        let scorer = Scorer(outputs: outputs)
        let (score, decodedGuess) = scorer.calculateScore()
        ts.fitnessScore = score
        guard let tz = ts as? TSLearnZoeName else { preconditionFailure() }
        tz.attemptedZName = decodedGuess
        return score
    }
}

extension Character {
    var asciiValue: Int {
        get {
            let s = String(self).unicodeScalars
            return Int(s[s.startIndex].value)
        }
    }
}

private class Scorer {
    let guess: UInt64
    var huffZoe: UInt64 = 0
//    let zName = "Zoe Bishop"
    let zName = "Christian H"
    let zNameCount: UInt64
    let zero: UInt64 = 0

    init(outputs: [Double?]) {
        zNameCount = UInt64(zName.count)
        for vc: UInt64 in zero..<zNameCount { huffZoe <<= 4; huffZoe |= vc }

        let guess: Double = outputs.compactMap({$0}).reduce(0.0, +)
        if guess == Double.nan || guess == Double.infinity || guess == -Double.infinity || guess < 0 {
            self.guess = 0
        } else {
            self.guess = UInt64(ceil(guess))
        }
    }

    func calculateScore() -> (Double, String) {
//        let s = String(format: "0x%qX", huffZoe)
//        print(s)

        var decoded = String()
        var workingCopy = huffZoe

        workingCopy = guess
        decoded.removeAll(keepingCapacity: true)
        for _ in zero..<zNameCount {
            let ibs = Int(workingCopy & UInt64(0x0F)) % zName.count
            let indexToBitString = zName.index(zName.startIndex, offsetBy: ibs)
            workingCopy >>= 4

            decoded.insert(Character(String(zName[indexToBitString...indexToBitString])), at: decoded.startIndex)
        }

//        let t = String(format: "0x%qX", guess)
//        print(t, decoded)

        let finalScore = abs(Double(guess) - Double(huffZoe))  // Try for -27.5
        return (finalScore, decoded)
    }
}
