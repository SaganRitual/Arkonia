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

protocol BreederFitnessTester {
    func administerTest(to testSubject: BreederTestSubject) -> (Double, String)?
}

protocol BreederTestSubjectFactory {
    func makeTestSubject() -> BreederTestSubject
}

protocol BreederTestSubjectAPI {
    func setFitnessTester(_ tester: BreederFitnessTester)
}

protocol BreederTestSubjectProtocol {
    static func makeTestSubject() -> BreederTestSubject
    func spawn() -> BreederTestSubject
}

class BreederTestSubject {
    class func makeTestSubject() -> BreederTestSubject { fatalError() }
    func spawn() -> BreederTestSubject { fatalError() }
}

class BreederTestZoeBrain: BreederTestSubject {
    var brain: LayerOwnerProtocol!
    var genome: Genome!
    
    static var theFishNumber = 0
    let myFishNumber = BreederTestZoeBrain.theFishNumber
    
    class TSF: BreederTestSubjectFactory {
        let genome: Genome?

        init() { self.genome = nil }
        init(genome: Genome) { self.genome = genome }
        
        func makeTestSubject() -> BreederTestSubject {
            if let g = genome {
                return BreederTestZoeBrain(genome: g, brain: nil)
            }
            
            // Random genome, as of 19Nov2018
            return BreederTestZoeBrain.makeTestSubject()
        }
    }

    private init(genome: Genome?, brain: LayerOwnerProtocol?) {
        if let g = genome {
            self.genome = g
            if let b = brain { self.brain = b }
            else { self.brain = BreederTestZoeBrain.makeBrain(from: g) }
            
            return
        }
        
        self.genome = RandomnessGenerator.generateRandomGenome()
        self.brain = BreederTestZoeBrain.makeBrain(from: self.genome)
    }
    
    static func makeBrain(from genome: Genome) -> LayerOwnerProtocol {
        Decoder.d.setInput(to: genome).decode()
        return Translators.t.getBrain()
    }
    
    override class func makeTestSubject() -> BreederTestSubject {
        BreederTestZoeBrain.theFishNumber += 1
        return BreederTestZoeBrain(genome: nil, brain: nil)
    }
    
    class func makeTestSubject(with genome: Genome) -> BreederTestSubject{
        BreederTestZoeBrain.theFishNumber += 1
        return BreederTestZoeBrain(genome: genome, brain: nil)
    }
    
    class func setBreederTestSubjectFactory() {
        _ = Breeder.bb.setTestSubjectFactory(TSF())
    }
    
    override func spawn() -> BreederTestSubject {
        _ = Mutator.m.setInputGenome(genome).mutate()
        let mutatedGenome = Mutator.m.convertToGenome()
        let brain = BreederTestZoeBrain.makeBrain(from: mutatedGenome)
        return BreederTestZoeBrain(genome: mutatedGenome, brain: brain)
    }
}

class BreederTestSubjectMockBrain: BreederTestSubject {
    class TSF: BreederTestSubjectFactory {
        func makeTestSubject() -> BreederTestSubject {
            return BreederTestSubjectMockBrain.makeTestSubject()
        }
    }
    
    var myFishNumber = 0
    
    override class func makeTestSubject() -> BreederTestSubject {
        return BreederTestSubjectMockBrain()
    }
    
    class func setBreederTestSubjectFactory() {
        _ = Breeder.bb.setTestSubjectFactory(TSF())
    }
    
    override func spawn() -> BreederTestSubject {
        let n = BreederTestSubjectMockBrain.makeTestSubject() as! BreederTestSubjectMockBrain
        n.myFishNumber = Int.random(in: -10000...10000)
        return n
    }
}

class MockBrainFitnessTester: BreederFitnessTester {
    func administerTest(to testSubject: BreederTestSubject) -> (Double, String)? {
        let d = Double((testSubject as! BreederTestSubjectMockBrain).myFishNumber)
        return (abs(d), "I have nothing to say")
    }
}

class ZoeBrainFitnessTester: BreederFitnessTester {
    let zName = "Zoe Bishop"
    let uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let lowercase = "abcdefghijklmnopqrstuvwxyz"
    var symbolcase = ZoeBrainFitnessTester.makeSymbolCase()
    
    func administerTest(to testSubject: BreederTestSubject) -> (Double, String)? {
        let ts = testSubject as! BreederTestZoeBrain
        let sensoryInput: [Double] = [1, 1, 1, 1, 1]
        guard let outputs = ts.brain.stimulate(inputs: sensoryInput) else { return nil }
        
        return getFitnessScore(for: outputs)
    }
    
    func displayZoeMatch(outputs: [Double]) -> [Double] {
        
        var zIndex = zName.startIndex
        for output in outputs {
            let zSlice = zName[zIndex...]
            let zChar = zSlice.first!
            
            let chopped = Int(output.remainder(dividingBy: 27.0).rounded())
            if chopped < 0 { print("chopped = \(chopped)"); raise(SIGINT) }
            let isUppercase = String().isUppercase(zChar)
            let whichCase = isUppercase ? uppercase : lowercase
            let characterIndex = whichCase.index(whichCase.startIndex, offsetBy: chopped)
            print(whichCase[characterIndex], terminator: "")
            
            zIndex = zName.index(after: zIndex)
        }
        
        return []
    }
    
    private func getFitnessScore(for outputs: [Double]) -> (Double, String) {
        var scoreForTheseOutputs = 0.0
        var whichCase = uppercase
        var resultString = String()

        for (expectedCharacter, ss) in zip(zName, 0...) {
            var modulo = Int(outputs[ss]) % 26
            var amodulo = abs(modulo)
            
            var inputCharacterValue = UnicodeScalar(amodulo)!.value
            var inputCharacter = Character(UnicodeScalar(inputCharacterValue)!)
            
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
            
            inputCharacterValue += UnicodeScalar(String(whichCase.first!))!.value
            inputCharacter = Character(UnicodeScalar(inputCharacterValue)!)
            
            // For upper and lowercase, display the letter from the brain outputs.
            // For symbols -- to catch the " " -- we display greek symbols
            let displaySymbol = (whichCase == symbolcase) ?
                UnicodeScalar(inputCharacterValue + UnicodeScalar("\u{03B1}")!.value)! :
                UnicodeScalar(inputCharacterValue)!

            resultString += String(displaySymbol)

            let zCharOffset = whichCase.firstIndex(of: expectedCharacter)!
            let iCharOffset = whichCase.firstIndex(of: inputCharacter)!
            let distance = whichCase.distance(from: zCharOffset, to: iCharOffset)
            
            scoreForTheseOutputs += Double(abs(distance)).dTruncate()
        }
        
        resultString += ": " + String(scoreForTheseOutputs)
        
        return (scoreForTheseOutputs, resultString)
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
