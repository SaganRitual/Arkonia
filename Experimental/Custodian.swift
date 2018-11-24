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
    var aboriginalTestSubject: TSHandle?
    var fitnessTester: BreederFitnessTester?
    
    let tsRelay: TSRelay
    let scoringFunction: FitnessTestFunction
    let factoryFunction: TestSubjectFactoryFunction
    
    init(aboriginalTestSubject: TSHandle? = nil, scoringFunction: @escaping FitnessTestFunction,
         factoryFunction: @escaping TestSubjectFactoryFunction) {
        
        if let a = aboriginalTestSubject { self.aboriginalTestSubject = a }
        else {
            let howManyGenes = selectionControls.howManyGenes
            self.aboriginalTestSubject =
                RandomnessGenerator.generateRandomTestSubject(howManyGenes: howManyGenes)
        }
        
        self.scoringFunction = scoringFunction; self.factoryFunction = factoryFunction
        self.tsRelay = TSRelay()
        
        self.selector = Selector(tsRelay)
        
        // Get the aboriginal's fitness score as the
        // first one to beat. Also make sure the aboriginal
        // survives the test.
        let g = Generation(tsRelay)
        let _ = g.addTestSubject()
        self.bestTestSubject = g.submitToTest(with: testInputs)
    }
    
    func makeGeneration(from ancestor: TSHandle) -> Generation {
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
        
        let handleDudness = { () -> Bool in
            if self.dudCounter < 5 { return true }

            self.dudCounter = 0

            if var p = self.promisingLines, !p.isEmpty {
                self.bestTestSubject = p.popLast()
                return true
            }

            print("Even the aboriginal was a dud")
            return false
        }

        while numberOfGenerations > 0 {
            defer { numberOfGenerations -= 1 }
            
            let selected = select()
            trackDudness(selected)
            
            if self.bestTestSubject == nil
                { self.bestTestSubject = selected; continue }
            
            if dudCounter == 0 { archiveWinner(bestTestSubject!) }
            else { if !handleDudness() { return } }
        }
    }
}

class TestSubjectFactory {
    let tsRelay: TSRelay
    
    init(_ tsRelay: TSRelay) { self.tsRelay = tsRelay }

    func makeTestSubject(from parent: TSHandle) -> TSHandle {
        let genome = tsRelay.getGenome(of: parent)
        
        testSubjects[testSubject.myFishNumber] = testSubject
        return testSubject.myFishNumber
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

