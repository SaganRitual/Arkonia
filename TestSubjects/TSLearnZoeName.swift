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

class TSLearnZoeName: TSTestSubject {
    var attemptedZName = String()

    override init(genome: Genome, brain: NeuralNetProtocol) {
        super.init(genome: genome, brain: brain)

        setSelectionControls()
    }

    func setSelectionControls() {
        selectionControls.howManySenses = 5
        selectionControls.howManyLayersInStarter = 5
        selectionControls.howManyMotorNeurons = "Zoe Bishop".count
    }
}

class TSZoeFactory: TestSubjectFactory {
    override func makeFitnessTester() -> FTFitnessTester {
        precondition(selectionControlsSet)
        return FTLearnZoeName()
    }

    override func makeTestSubject(parent: TSTestSubject, mutate: Bool) -> TSTestSubject? {
        precondition(selectionControlsSet)
        return makeTestSubject(parentGenome: parent.genome[...], mutate: mutate)
    }

    override func makeTestSubject(parentGenome: GenomeSlice, mutate: Bool) -> TSTestSubject? {
        precondition(selectionControlsSet)
        let mutated = super.mutate(parentGenome: parentGenome)

        guard decoder.setInput(to: mutated).decode() else { return nil }

        let brain = Translators.t.getBrain()
        return TSLearnZoeName(genome: String(mutated), brain: brain)
    }
}

class FTLearnZoeName: FTFitnessTester {
    var charactersMatched = 0

    override func doScoringStuff(_ ts: TSTestSubject, _ outputs: [Double?]) -> Double {
        guard let tz = ts as? TSLearnZoeName else { fatalError() }

        var scoreForTheseOutputs = 0.0

        let scorer = Scorer(outputs: outputs)
        let score = scorer.calculateScore()

        scoreForTheseOutputs += score
        tz.attemptedZName = scorer.attemptedZName
//        print(tz.attemptedZName, scoreForTheseOutputs)

        return scoreForTheseOutputs
    }
}

private class Scorer {
    let uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let lowercase = "abcdefghijklmnopqrstuvwxyz"
    var symbolcase = Scorer.makeSymbolCase()
    var whichCase: String

    let zName = "Zoe Bishop"
    var attemptedZName = String()
    var charactersMatched = 0
    var outputs: [Double]
    var previousCharacterValue: Int?
    var scoreForTheseOutputs = 0.0

    var modulo = 0
    var amodulo = 0
    var inputCharacterValue: UInt32 = 0
    var inputCharacter: Character!

    init(outputs: [Double?]) {
        self.outputs = outputs.compactMap({$0})
        self.whichCase = uppercase
    }

    func getCase(_ expectedCharacter: Character, _ ss: Int) -> String {
        if String().isUppercase(expectedCharacter) {
            whichCase = uppercase
        } else if String().isLowercase(expectedCharacter) {
            whichCase = lowercase
        } else {
            whichCase = symbolcase
            modulo = Int(outputs[ss]) % 32
            amodulo = abs(modulo)
            inputCharacterValue = UnicodeScalar(amodulo)!.value
            inputCharacter = Character(UnicodeScalar(inputCharacterValue)!)
        }

        return whichCase
    }

    func calculateScore() -> Double {
        let symbolLookup: String = {
            var s = String()
            for i in 0..<32 { s.append(String(UnicodeScalar(i) ?? "🔧")) }
            return s
        }()

        for (expectedCharacter, ss) in zip(zName, 0..<outputs.count) {
            if outputs[ss] > Double(Int.max) { modulo = Int.max }
            if outputs[ss] < Double(-Int.max) { modulo = Int.min }

            var whichCase = getCase(expectedCharacter, ss)

            modulo %= (whichCase == symbolcase) ? 32 : 26
            amodulo = abs(modulo)

            inputCharacterValue = UnicodeScalar(amodulo)!.value
            inputCharacter = Character(UnicodeScalar(inputCharacterValue)!)

            if let p = previousCharacterValue, inputCharacterValue == p {
                scoreForTheseOutputs += 10
//                print("Repeat \(inputCharacterValue) costs 10: \(scoreForTheseOutputs)", to: &Log.L)
            }

            previousCharacterValue = Int(inputCharacterValue)

            inputCharacterValue += UnicodeScalar(String(whichCase.first!))!.value
            inputCharacter = Character(UnicodeScalar(inputCharacterValue)!)

//            print("Character \(inputCharacterValue) to \(testOutput)", to: &Log.L)
            self.attemptedZName.append(inputCharacter)

            let zCharOffset = whichCase.firstIndex(of: expectedCharacter)!
            var iCharOffset = whichCase.startIndex

            if let iCharOffset_ = whichCase.firstIndex(of: inputCharacter) {
                iCharOffset = iCharOffset_
            } else {
                whichCase = symbolLookup
                iCharOffset = whichCase.index(whichCase.startIndex, offsetBy: Int(inputCharacterValue))
            }

            let distance = whichCase.distance(from: zCharOffset, to: iCharOffset)

            let count = Double(abs(distance)).dTruncate()
            scoreForTheseOutputs += count
//            print("Normal cost for \(count) from \(ss + 1) outputs \(outputs.count) -> \(scoreForTheseOutputs)", to: &Log.L)
        }

        let shorteningCost = Double(26 * (zName.count - attemptedZName.count))
        scoreForTheseOutputs += shorteningCost
//        let p1 = "Zoe Bishop".count - testOutput.count
//        print("Cost for dropping \(p1) characters -> \(shorteningCost); total = \(scoreForTheseOutputs)", to: &Log.L)

        return scoreForTheseOutputs
    }

    private static func makeSymbolCase() -> String {
        var symbolcase = [Character]()

        let symbols = " !\"#$%&'()*+,-./0123456789:;<=>"
        for charCode in 0..<symbols.count {    // Closed range; space is code 32
            let offset = symbols.index(symbols.startIndex, offsetBy: charCode)
            let symbol = String(symbols[offset])
            let char = Character(symbol)
            symbolcase.append(char)
        }

        return String(symbolcase)
    }
}
