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

class TSTestGroup {
    var testSubjects = [TSHandle : TSTestSubject]()
    
    func reset() { testSubjects = [:] }
    
    subscript(which: TSHandle) -> TSTestSubject? {
        get { return testSubjects[which] } set { testSubjects[which] = newValue } }
}

struct TSArchivableSubject: Hashable {
    let tsHandle: TSHandle
    let genome: Genome
    let score: Double
    
    init(tsHandle: TSHandle, genome: Genome, score: Double) {
        self.tsHandle = tsHandle; self.genome = genome; self.score = score
    }
}

class Custodian {
    let selector: Selector
    var numberOfGenerations = selectionControls.howManyGenerations
    var bestTestSubject: TSHandle?
    let testInputs = [1.0, 1.0, 1.0, 1.0]
    var dudCounter = 0
    var promisingLines = [TSArchivableSubject]()
    var studBeingVetted: TSArchivableSubject?
    var aboriginalGenome: Genome
    
    let tsRelay: TSRelay
    let decoder = Decoder()
    let callbacks: Callbacks
    var studGenome: Genome

    var testSubjects = TSTestGroup()
    
    init(starter: Genome? = nil, callbacks: Custodian.Callbacks) {
        if let a = starter { self.aboriginalGenome = a }
        else {
            let singleNeuronPassThroughPort = "N_A(true)_W(b[1]v[1])_B(b[0]v[0]_"
            let sag: Genome = { () -> Genome in
                var dag = Genome("L_")
                for _ in 0..<selectionControls.howManySenses {
                    dag += singleNeuronPassThroughPort
                }
                return dag
            }()
            
            self.aboriginalGenome = sag
        }
        
        self.callbacks = callbacks
        self.tsRelay = TSRelay(testSubjects)
        self.selector = Selector(tsRelay, testGroup: testSubjects)
        
        // Get the aboriginal's fitness score as the
        // first one to beat. Also good to make sure the aboriginal
        // survives the test.
        let generation = Generation(tsRelay, testSubjects: testSubjects)
        let aboriginalAncestor =
            testSubjectFactory.makeTestSubject(genome: self.aboriginalGenome, mutate: false)
        testSubjects[aboriginalAncestor.myFishNumber] = aboriginalAncestor

        let _ = generation.addTestSubject(aboriginalAncestor.myFishNumber)
        self.bestTestSubject = generation.submitToTest(with: testInputs)
        
        // aboriginalGenome is definitely set, at the entry to
        // this function, and so far he's the best thing going.
        self.studGenome = self.aboriginalGenome
        self.archivePromisingStud(aboriginalAncestor.myFishNumber)
    }
    
    func archivePromisingStud(_ winner: TSHandle) {

        if let vettee = self.studBeingVetted {
            if vettee.tsHandle == winner {
                // We're vetting someone currently, and he has won again;
                // nothing to do until we get a new winner.
                return
            } else {
                // We have a new winner; archive the currently-being-vetted
                // guy, and now start vetting the new guy
                self.promisingLines.append(vettee)
                self.studBeingVetted = nil      // In case it makes debugging easier
            }
        }
        
        let stud = self.testSubjects.testSubjects[winner]!
        let genome = stud.genome
        let score = stud.getFitnessScore()!
        let forArchival = TSArchivableSubject(tsHandle: winner, genome: genome, score: score)
        self.studBeingVetted = forArchival
    }

    func makeGeneration(mutate: Bool = true, force thisMany: Int? = nil) -> Generation {
        let howManySubjectsPerGeneration = (thisMany == nil) ?
            selectionControls.howManySubjectsPerGeneration : thisMany!
        
        let generation = Generation(tsRelay, testSubjects: testSubjects)
        
        for _ in 0..<howManySubjectsPerGeneration {
            let testSubject = testSubjectFactory.makeTestSubject(genome: self.studGenome, mutate: mutate)
            testSubjects[testSubject.myFishNumber] = testSubject
            generation.addTestSubject(testSubject.myFishNumber)
        }
        
        return generation //Generation(tsRelay, testSubjects: testSubjects)
    }
    
    func select() -> TSHandle? {
        let generation = makeGeneration()
        
        // At least one survived in this generation
        guard let candidate = selector.select(from: generation, for: testInputs) else { print("E"); return nil }

        // If I'm not vetting anyone yet (meaning, we just started with the aboriginal alone)
        guard let reigningChampion = self.studBeingVetted else { return candidate }

        precondition(candidate != reigningChampion.tsHandle, "Sanity check")

        guard let candidateScore = tsRelay.getFitnessScore(for: candidate) else {
            preconditionFailure("Generation returned a candidate that appears to have died during the test")
        }

        return (candidateScore < reigningChampion.score) ? candidate : reigningChampion.tsHandle
    }
    
    func track() {
        let dudIfSameGuy = { (_ newGuy: TSHandle, _ currentGuy: TSHandle) -> Void in
            if newGuy == currentGuy { self.dudCounter += 1 }
            else { self.dudCounter = 0 }
        }
        
        let trackDudness = { (_ selection: TSHandle?) -> Void in
            if let survivor = selection {
                if let myCurrentBest = self.bestTestSubject
                    { dudIfSameGuy(survivor, myCurrentBest) }
                
            } else { self.dudCounter += 1 }  // The whole generation died
        }
        
        let isTooMuchDudness = { () -> Bool in
            if self.dudCounter < 5 { return false }

            self.dudCounter = 0

            if let zombie = self.promisingLines.popLast() {
                self.studBeingVetted = nil                  // This guy was too dudly, goodbye
                self.bestTestSubject = zombie.tsHandle      // Bring back his parent
                self.studGenome = zombie.genome
                return false                                // We haven't given up on anti-dudding yet
            }

            print("Even the aboriginal was a dud")
            return true
        }

        while numberOfGenerations > 0 {
            defer { numberOfGenerations -= 1 }
            
            self.testSubjects.reset()   // New generation; kill off the old one
            let selected = select()

            trackDudness(selected)

            if self.bestTestSubject == nil
                { self.bestTestSubject = selected; continue }
            
            if dudCounter == 0 {
                self.bestTestSubject = selected
                archivePromisingStud(bestTestSubject!)
                continue
            }
            
            if isTooMuchDudness() { return }
        }
    }
}

extension Custodian {
    class Callbacks {
        var testSubjectFactory: SelectionTestSubjectFactory?
        var fitnessTester: SelectionFitnessTester?
        
        init(testSubjectFactory: SelectionTestSubjectFactory, fitnessTester: SelectionFitnessTester) {
            self.testSubjectFactory = testSubjectFactory; self.fitnessTester = fitnessTester
        }
        
        init() { }
    }
}

protocol SelectionTestSubjectFactory {
    func makeTestSubject(genome: Genome, mutate: Bool) -> TSTestSubject
}

protocol SelectionFitnessTester {
    func administerTest(to testSubject: TSTestSubject, for sensoryInput: [Double]) -> [Double]?
    func setFitnessScore(for testSubject: TSTestSubject, outputs: [Double]?)
    func getFitnessScore(for testSubject: TSTestSubject) -> Double?
}

class TestSubjectFactory: SelectionTestSubjectFactory {
    let tsRelay: TSRelay
    let decoder: Decoder
    let callbacks: Custodian.Callbacks
    
    init(_ tsRelay: TSRelay, decoder: Decoder, callbacks: Custodian.Callbacks) {
        self.tsRelay = tsRelay; self.decoder = decoder;
        self.callbacks = callbacks; callbacks.testSubjectFactory = self
    }

    func makeTestSubject(genome: Genome, mutate: Bool) -> TSTestSubject {
        var maybeMutated = genome
        if mutate {
            let _ = Mutator.m.setInputGenome(genome).mutate()
            maybeMutated = Mutator.m.convertToGenome()
        }

        decoder.setInput(to: maybeMutated).decode()
        let brain = Translators.t.getBrain()

        return TSTestSubject(with: maybeMutated, brain: brain, callbacks: callbacks)
    }
}

class TestSubjectFitnessTester: SelectionFitnessTester {
    init(callbacks: Custodian.Callbacks) { callbacks.fitnessTester = self }
    
    func administerTest(to testSubject: TSTestSubject, for sensoryInput: [Double]) -> [Double]? {
        guard let b = testSubject.brain else { preconditionFailure("No brain, no test.") }
        let outputs = b.stimulate(inputs: sensoryInput)
        setFitnessScore(for: testSubject, outputs: outputs)
        return outputs
    }
    
    func getFitnessScore(for testSubject: TSTestSubject) -> Double?
        { return testSubject.getFitnessScore() }
    
    func setFitnessScore(for testSubject: TSTestSubject, outputs: [Double]?) {
        guard let outputs = outputs else { return }
        let totalOutput = outputs.reduce(0, +)
        testSubject.setFitnessScore(abs(totalOutput - 17))    // The number I want the brains to guess
    }
}

class Selector {
    var bestTestSubject: TSHandle?
    var fullDetails: TSTestSubject?
    var generations = [Generation]()
    var testInputs = [Double]()
    var generationCounter = 0
    var tsRelay: TSRelay
    var testGroup: TSTestGroup

    init(_ tsRelay: TSRelay, testGroup: TSTestGroup) { self.tsRelay = tsRelay; self.testGroup = testGroup }

    private func administerTest(to generation: Generation, for inputs: [Double]) -> TSHandle? {
        guard let bestSubjectOfGeneration = generation.submitToTest(with: inputs) else { return nil }

        if self.bestTestSubject == nil {
            self.bestTestSubject = bestSubjectOfGeneration
            self.fullDetails = testGroup.testSubjects[bestSubjectOfGeneration]
            return self.bestTestSubject
        }
        
        guard let fullDetailsOfMyBest = self.fullDetails else {
            preconditionFailure("Best test subject is set, but no full details")
        }
        
        guard let hisScore = tsRelay.getFitnessScore(for: bestSubjectOfGeneration) else {
            preconditionFailure("Shouldn't get a winner with a nil score")
        }
        
        guard let myScore = fullDetailsOfMyBest.getFitnessScore() else {
            preconditionFailure("Our best test subject has lost his score")
        }
        
        if hisScore < myScore {
            self.bestTestSubject = bestSubjectOfGeneration
            self.fullDetails = testGroup.testSubjects[bestSubjectOfGeneration]
            return self.bestTestSubject
        }
        
        return nil
    }
    
    func select(from generation: Generation, for inputs: [Double]) -> TSHandle? {
        return administerTest(to: generation, for: inputs)
    }
}
