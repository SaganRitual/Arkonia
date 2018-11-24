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

struct SelectionControls {
    var howManySenses = 5
    var howManyMotorNeurons = 5
    var howManyGenerations = 100
    var howManyGenes = 200
    var howManySubjectsPerGeneration = 100
    var theFishNumber = 0
}

var selectionControls = SelectionControls()

class Custodian {
    let selector: Selector
    var numberOfGenerations = selectionControls.howManyGenerations
    var bestTestSubject: TSHandle?
    let testInputs = [1.0, 1.0, 1.0, 1.0]
    var dudCounter = 0
    var promisingLines: [TSHandle]?
    var aboriginalGenome: Genome?
    var fitnessTester: BreederFitnessTester?
    
    let tsRelay: TSRelay
    let scoringFunction: FitnessTestFunction
    let factoryFunction: TestSubjectFactoryFunction
    let decoder = Decoder()

    var testSubjects = [TSHandle : TSTestSubject]()
    
    init(aboriginalGenome: Genome?, scoringFunction: @escaping FitnessTestFunction,
         factoryFunction: @escaping TestSubjectFactoryFunction) {
        
        if let a = aboriginalGenome { self.aboriginalGenome = a }
        else {
            let howManyGenes = selectionControls.howManyGenes
            self.aboriginalGenome =
                RandomnessGenerator.generateRandomGenome(howManyGenes: howManyGenes)
        }
        
        self.scoringFunction = scoringFunction; self.factoryFunction = factoryFunction
        self.tsRelay = TSRelay(testSubjects)
        self.selector = Selector(tsRelay)
        
        // Get the aboriginal's fitness score as the
        // first one to beat. Also good to make sure the aboriginal
        // survives the test.
        let generation = Generation(tsRelay)
        let aboriginalAncestor = factoryFunction(self.aboriginalGenome!, false)
        testSubjects[aboriginalAncestor.myFishNumber] = aboriginalAncestor

        let _ = generation.addTestSubject(aboriginalAncestor.myFishNumber)
        self.bestTestSubject = generation.submitToTest(with: testInputs)
    }
    
    func makeGeneration(from stud: TSHandle, force thisMany: Int? = nil) -> Generation {
        let howManyGenerations = (thisMany == nil) ? selectionControls.howManyGenerations : thisMany!
        let studGenome = testSubjects[stud]!.genome
        
        var generation = Generation(tsRelay)
        
        for _ in 0..<howManyGenerations {
            let testSubject = factoryFunction(studGenome, true)
            testSubjects[testSubject.myFishNumber] = testSubject
            generation.addTestSubject(testSubject.myFishNumber)
        }
        
        return Generation(tsRelay)
    }
    
    func select() -> TSHandle? {
        guard let stud = self.bestTestSubject else { preconditionFailure("Nothing to breed from") }

        let generation = makeGeneration(from: stud)
        
        guard let candidate = selector.select(from: generation, for: testInputs) else { return nil }
        guard let candidateScore = tsRelay.getFitnessScore(for: candidate) else {
            preconditionFailure("Generation returned a candidate that appears to have died during the test")
        }
        
        guard let myBest = self.bestTestSubject else { self.bestTestSubject = candidate; return candidate }
        guard let myBestScore = tsRelay.getFitnessScore(for: myBest) else {
            preconditionFailure("My best test subject has died while sitting on the shelf doing nothing")
        }

        if candidateScore < myBestScore { self.bestTestSubject = candidate }
        
        return self.bestTestSubject
    }
    
    func setFitnessTester(_ tester: BreederFitnessTester) { self.fitnessTester = tester }
    
    func track() {
        let dudIfSameGuy = { (_ newGuy: TSHandle, _ currentGuy: TSHandle) -> Void in
            let newFish = self.tsRelay.getFishNumber(for: newGuy)
            let currentFish = self.tsRelay.getFishNumber(for: currentGuy)
            
            if newFish == currentFish { self.dudCounter += 1 }
            else { self.dudCounter = 0 }
        }
        
        let trackDudness = { (_ selection: TSHandle?) -> Void in
            if let survivor = selection {
                if let myCurrentBest = self.bestTestSubject
                    { dudIfSameGuy(survivor, myCurrentBest) }
                
            } else { self.dudCounter += 1 }  // The whole generation died
        }
        
        let archiveWinner = { (_ winner: TSHandle) -> Void in
            if self.promisingLines == nil { self.promisingLines = [] }
            self.promisingLines!.append(winner)
        }
        
        let isTooMuchDudness = { () -> Bool in
            if self.dudCounter < 5 { return false }

            self.dudCounter = 0

            if var p = self.promisingLines, !p.isEmpty {
                self.bestTestSubject = p.popLast()
                return false
            }

            print("Even the aboriginal was a dud")
            return true
        }

        while numberOfGenerations > 0 {
            defer { numberOfGenerations -= 1 }
            
            let selected = select()
            trackDudness(selected)
            
            if self.bestTestSubject == nil
                { self.bestTestSubject = selected; continue }
            
            if dudCounter == 0 { archiveWinner(bestTestSubject!) }
            else { if isTooMuchDudness() { return } }
        }
    }
}

class TestSubjectFactory {
    let tsRelay: TSRelay
    let decoder: Decoder
    
    init(_ tsRelay: TSRelay, decoder: Decoder) { self.tsRelay = tsRelay; self.decoder = decoder }

    func makeTestSubject(_ genome: Genome, _ mutate: Bool) -> TSTestSubject {
        var maybeMutated = genome
        if mutate {
            let _ = Mutator.m.setInputGenome(genome).mutate()
            maybeMutated = Mutator.m.convertToGenome()
        }
        
        decoder.setInput(to: maybeMutated).decode()
        let brain = Translators.t.getBrain()
        
        return TSTestSubject(with: maybeMutated, brain: brain)
    }
}

class Selector {
    var bestTestSubject: TSHandle?
    var generations = [Generation]()
    var testInputs = [Double]()
    var generationCounter = 0
    var tsRelay: TSRelay
    
    init(_ tsRelay: TSRelay) { self.tsRelay = tsRelay }
    
    private func administerTest(to generation: Generation, for inputs: [Double]) -> TSHandle? {
        guard let bestSubjectOfGeneration = generation.submitToTest(with: inputs) else { return nil }

        guard let myBestTestSubject = self.bestTestSubject else {
            self.bestTestSubject = bestSubjectOfGeneration
            return self.bestTestSubject
        }
        
        guard let hisScore = tsRelay.getFitnessScore(for: bestSubjectOfGeneration) else {
            preconditionFailure("Shouldn't get a winner with a nil score")
        }
        
        guard let myScore = tsRelay.getFitnessScore(for: myBestTestSubject) else {
            preconditionFailure("Our best test subject has lost his score")
        }
        
        if hisScore < myScore { self.bestTestSubject = bestSubjectOfGeneration }
        
        return self.bestTestSubject
    }
    
    func select(from generation: Generation, for inputs: [Double]) -> TSHandle? {
        _ = administerTest(to: generation, for: inputs)
        return self.bestTestSubject
    }
}

