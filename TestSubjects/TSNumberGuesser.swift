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

class TSNumberGuesser: BreederTestSubject {
    class TSF: BreederTestSubjectFactory {
        let genome: Genome?
        
        init(genome: Genome, numberOfSenses: Int = 5, numberOfMotorNeurons: Int = 5,
             numberOfGenerations: Int = 50, numberOfTestSubjectsPerGeneration: Int = 50) {
            Translators.numberOfSenses = numberOfSenses
            Translators.numberOfMotorNeurons = numberOfMotorNeurons
            Breeder.howManyGenerations = numberOfGenerations
            Breeder.howManyTestSubjectsPerGeneration = numberOfTestSubjectsPerGeneration
            self.genome = genome
        }

        func makeTestSubject() -> BreederTestSubject {
            if let g = genome {
                return TSNumberGuesser.makeTestSubject(with: g)
            }
            
            // Random genome, as of 19Nov2018
            return TSNumberGuesser.makeTestSubject()
        }
    }
    
    private init(genome: Genome?, brain: LayerOwnerProtocol?) {
        if let g = genome {
            super.init(genome: g)

            if let b = brain { self.brain = b }
            else { self.brain = TSNumberGuesser.makeBrain(from: g) }
            
            return
        }
        
        super.init()
        self.genome = RandomnessGenerator.generateRandomGenome()
        self.brain = TSNumberGuesser.makeBrain(from: self.genome)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    required init(genome: Genome) {
        fatalError("init(genome:) has not been implemented")
    }
    
    class func makeTestSubject(with genome: Genome) -> BreederTestSubject{
        TSNumberGuesser.theFishNumber += 1
        return TSNumberGuesser(genome: genome, brain: nil)
    }
    
    override class func makeBrain(from genome: Genome) -> LayerOwnerProtocol {
        Decoder.d.setInput(to: genome).decode()
        return Translators.t.getBrain()
    }

    override class func makeTestSubject() -> BreederTestSubject {
        return TSNumberGuesser(genome: nil, brain: nil)
    }
    
    class func setBreederTestSubjectFactory(factory: TSF) {
        _ = Breeder.bb.setTestSubjectFactory(factory)
    }
    
    override func spawn() -> BreederTestSubject? {
        _ = Mutator.m.setInputGenome(genome).mutate()
        let mutatedGenome = Mutator.m.convertToGenome()
        if mutatedGenome == self.genome { return nil }
        
        let brain = TSNumberGuesser.makeBrain(from: mutatedGenome)
        return TSNumberGuesser(genome: mutatedGenome, brain: brain)
    }
}

class FTNumberGuesser: BreederFitnessTester {
    var sensoryInput = [Double]()
    
    func administerTest(to testSubject: BreederTestSubject) -> (Double, String)? {
        let ts = testSubject as! TSNumberGuesser
        self.sensoryInput = Array(repeating: 1.0, count: Translators.numberOfSenses)
        guard let outputs = ts.brain.stimulate(inputs: sensoryInput) else { return nil }
        
        return getFitnessScore(for: outputs)
    }
    
    internal func getFitnessScore(for outputs: [Double]) -> (Double, String) {
        let score = abs(outputs.reduce(0, +) - 17)
//        let score = abs(sensoryInput[0] - 17)
//        print("New best score \(score.sTruncate())")
        return (score, "New best score \(score.sTruncate())")
    }
}

class TSNumberGuesserSetup {
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

    let numberOfSenses = 5
    let numberOfMotorNeurons = 5
    let numberOfGenerations = 100
    let numberOfTestSubjectsPerGeneration = 100

    var newGenome = Genome()
    let testBreeder: TestBreeder
    
    init() {
        for _ in 0..<5 {
            newGenome += "L_"
            for _ in 0..<numberOfSenses {
                newGenome += "N_"
                var active = true
                for _ in 0..<5 {
                    active = !active
                    if active { newGenome += "A(true)_W(b[1]v[11])_B(b[1]v[12])_T(b[1]v[17])_" }
                    else { newGenome += "A(false)_" }
                }
            }
        }

        let testSubjectFactory =
            TSNumberGuesser.TSF(genome: newGenome, numberOfSenses: numberOfSenses, numberOfMotorNeurons: numberOfMotorNeurons,
                                numberOfGenerations: numberOfGenerations, numberOfTestSubjectsPerGeneration: numberOfTestSubjectsPerGeneration)
        
        _ = Breeder.bb.setTestSubjectFactory(testSubjectFactory)
        Breeder.bb.setFitnessTester(FTNumberGuesser())
        
        self.testBreeder = TestBreeder()
    }
    
    func run() {
        let v = RepeatingTimer(timeInterval: 0.1)
        var bestFitnessScore = 0.0
        v.eventHandler = { bestFitnessScore = self.testBreeder.select() }
        v.resume()
        while testBreeder.shouldKeepRunning {  }
        print("Best score \(bestFitnessScore)", Breeder.bb.getBestGenome())
    }
    
    func tick() {
        _ = testBreeder.select()
    }
}

