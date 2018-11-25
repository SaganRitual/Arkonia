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
    override init(with genome: Genome, brain: BrainStem?, fitnessTester: TestSubjectFitnessTester) {
        super.init(with: genome, brain: brain, fitnessTester: fitnessTester)

        setSelectionControls()
    }
    
    func setSelectionControls() {
        selectionControls.howManySenses = 5
        selectionControls.howManyMotorNeurons = "Zoe Bishop".count
    }
}

class TSZoeFactory: TestSubjectFactory {
    override func makeTestSubject(genome: Genome, mutate: Bool) throws -> TSLearnZoeName {
        var maybeMutated = genome
        if mutate {
            let _ = Mutator.m.setInputGenome(genome).mutate()
            maybeMutated = Mutator.m.convertToGenome()
        }
        
        try decoder.setInput(to: maybeMutated).decode()
        let brain = Translators.t.getBrain()
        
        return TSLearnZoeName(with: maybeMutated, brain: brain, fitnessTester: fitnessTester)
    }
}

class FTLearnZoeName: TestSubjectFitnessTester {
    let zName = "Zoe Bishop"

    static var resultsArray = [Character("."), Character("."), Character("."), Character("."),
                        Character("."), Character("."), Character("."), Character("."),
                        Character("."), Character(".")]

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

fileprivate class Scorer {
    let uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let lowercase = "abcdefghijklmnopqrstuvwxyz"
    var symbolcase = Scorer.makeSymbolCase()
    var whichCase: String

    let zName: String
    var charactersMatched = 0
    var outputs: [Double]
    var previousCharacterValue: Int? = nil
    var scoreForTheseOutputs = 0.0
    
    var modulo = 0
    var amodulo = 0
    var inputCharacterValue: UInt32 = 0
    var inputCharacter: Character!

    init(_ zName: String, outputs: [Double]) {
        self.zName = zName; self.outputs = outputs; self.whichCase = uppercase
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

    func getScore() -> Double {
        for (expectedCharacter, ss) in zip(zName, 0..<outputs.count) {
            if outputs[ss] > Double(Int.max) { modulo = Int.max }
            if outputs[ss] < Double(-Int.max) { modulo = Int.min }

            modulo %= 26
            amodulo = abs(modulo)
            
            inputCharacterValue = UnicodeScalar(amodulo)!.value
            inputCharacter = Character(UnicodeScalar(inputCharacterValue)!)
            
            if let p = previousCharacterValue, inputCharacterValue == p {
                scoreForTheseOutputs += 20
            }
            
            previousCharacterValue = Int(inputCharacterValue)
            
            let whichCase = getCase(expectedCharacter, ss)
            
            inputCharacterValue += UnicodeScalar(String(whichCase.first!))!.value
            inputCharacter = Character(UnicodeScalar(inputCharacterValue)!)
            
            FTLearnZoeName.resultsArray[ss] = inputCharacter
            
            let zCharOffset = whichCase.firstIndex(of: expectedCharacter)!
            let iCharOffset = whichCase.firstIndex(of: inputCharacter)!
            let distance = whichCase.distance(from: zCharOffset, to: iCharOffset)
            
            scoreForTheseOutputs += Double(abs(distance)).dTruncate()
        }
        
        return scoreForTheseOutputs
    }
    
    private static func makeSymbolCase() -> String{
        var symbolcase = [Character]()
        
        for charCode in 0...32 {    // Closed range; space is code 32
            let char = Character(UnicodeScalar(charCode)!)
            symbolcase.append(char)
        }
        
        return String(symbolcase)
    }
}
