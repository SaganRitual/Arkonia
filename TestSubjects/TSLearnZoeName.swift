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

class TSLearnZoeName: BreederTestSubject {
    class TSF: BreederTestSubjectFactory {
        let genome: Genome?
        
        init() { self.genome = nil }
        
        init(genome: Genome, numberOfSenses: Int = 5, numberOfMotorNeurons: Int = 5,
             numberOfGenerations: Int = 50, numberOfTestSubjectsPerGeneration: Int = 50) {
            Translators.numberOfSenses = numberOfSenses
            Translators.numberOfMotorNeurons = numberOfMotorNeurons
            Breeder.howManyGenerations = numberOfGenerations
            Breeder.howManyTestSubjectsPerGeneration = numberOfTestSubjectsPerGeneration
            self.genome = genome
        }

        init(genome: Genome) { self.genome = genome }
        
        func makeTestSubject() -> BreederTestSubject {
            if let g = genome {
                return TSLearnZoeName(genome: g, brain: nil)
            }
            
            // Random genome, as of 19Nov2018
            return TSLearnZoeName.makeTestSubject()
        }
    }
    
    required internal init(genome: Genome?, brain: LayerOwnerProtocol?) {
        if let g = genome {
            super.init(genome: g)

            if let b = brain { self.brain = b }
            else { self.brain = TSLearnZoeName.makeBrain(from: g) }
            
            return
        }
        
        super.init()
        
        self.genome = RandomnessGenerator.generateRandomGenome()
        self.brain = TSLearnZoeName.makeBrain(from: self.genome)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    required init(genome: Genome) {
        fatalError("init(genome:) has not been implemented")
    }
    
    override class func makeBrain(from genome: Genome) -> LayerOwnerProtocol {
        Decoder.d.setInput(to: genome).decode()
        return Translators.t.getBrain()
    }
    
    override class func makeTestSubject() -> BreederTestSubject {
        TSLearnZoeName.theFishNumber += 1
        return TSLearnZoeName(genome: nil, brain: nil)
    }
    
    class func makeTestSubject(with genome: Genome) -> BreederTestSubject{
        TSLearnZoeName.theFishNumber += 1
        return TSLearnZoeName(genome: genome, brain: nil)
    }
    
    class func setBreederTestSubjectFactory() {
        _ = Breeder.bb.setTestSubjectFactory(TSF())
    }
    
    override func spawn() -> BreederTestSubject? {
        _ = Mutator.m.setInputGenome(genome).mutate()
        let mutatedGenome = Mutator.m.convertToGenome()
        if mutatedGenome == self.genome { return nil }
        
        let brain = TSLearnZoeName.makeBrain(from: mutatedGenome)
        return TSLearnZoeName(genome: mutatedGenome, brain: brain)
    }
}

class FTLearnZoeName: BreederFitnessTester {
    let zName = "Zoe Bishop"
    let uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let lowercase = "abcdefghijklmnopqrstuvwxyz"
    var symbolcase = FTLearnZoeName.makeSymbolCase()
    
    func administerTest(to testSubject: BreederTestSubject) -> (Double, String)? {
        let ts = testSubject as! TSLearnZoeName
        let sensoryInput: [Double] = [1, 1, 1, 1, 1]
        guard let outputs = ts.brain.stimulate(inputs: sensoryInput) else { return nil }
        
        return getFitnessScore(for: outputs)
    }
    
    var charactersMatched = 0
    internal func getFitnessScore(for outputs: [Double]) -> (Double, String) {
        var scoreForTheseOutputs = 0.0
        var whichCase = uppercase
        var resultString = String()
        var previousCharacterValue: Int? = nil
        
        for (expectedCharacter, ss) in zip(zName, 0..<(charactersMatched + 1)) {
            var modulo = Int(outputs[ss]) % 26
            var amodulo = abs(modulo)
            
            var inputCharacterValue = UnicodeScalar(amodulo)!.value
            var inputCharacter = Character(UnicodeScalar(inputCharacterValue)!)
            
            if let p = previousCharacterValue, inputCharacterValue == p {
                scoreForTheseOutputs += 20
            }
            
            previousCharacterValue = Int(inputCharacterValue)
            
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
        
        if scoreForTheseOutputs == 0 {
            charactersMatched += 1
            scoreForTheseOutputs = Double(abs(zName.count - charactersMatched))
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

class ZoeTestSubjectSetup {
    
    let numberOfSenses = 5
    let numberOfMotorNeurons = "Zoe Bishop".count
    let numberOfGenerations = 100
    let numberOfTestSubjectsPerGeneration = 100
    
    var newGenome = Genome()
    var testSubjectFactory: TSLearnZoeName.TSF?
    var testBreeder: TestBreeder?

    class TestBreeder {
        var shouldKeepRunning = true
        
        var currentGenerationNumber = 0
        func select() -> Double {
            let bestFitnessScore = Breeder.bb.breedAndSelect()
            
            currentGenerationNumber += 1
            if currentGenerationNumber >= Breeder.howManyGenerations || bestFitnessScore == 0 {
                self.shouldKeepRunning = false
            }
            
            return bestFitnessScore
        }
    }
    
    init() {
        newGenome += "L."
        for _ in 0..<numberOfSenses {
            newGenome += "N.A(true).W(b[1]v[1]).B(b[0]v[0]).T(b[5555]v[5555])."

        testSubjectFactory =
            TSLearnZoeName.TSF(genome: newGenome, numberOfSenses: numberOfSenses, numberOfMotorNeurons: numberOfMotorNeurons,
                               numberOfGenerations: numberOfGenerations, numberOfTestSubjectsPerGeneration: numberOfTestSubjectsPerGeneration)

            _ = Breeder.bb.setTestSubjectFactory(testSubjectFactory!)
            Breeder.bb.setFitnessTester(FTLearnZoeName())
            
            self.testBreeder = TestBreeder()
        }
    }
    
    func run() {
        let v = RepeatingTimer(timeInterval: 0.1)
        var bestFitnessScore = 0.0
        v.eventHandler = { bestFitnessScore = self.testBreeder!.select() }
        v.resume()
        while testBreeder!.shouldKeepRunning {  }
        print("Best score \(bestFitnessScore)", Breeder.bb.getBestGenome())
    }

}
