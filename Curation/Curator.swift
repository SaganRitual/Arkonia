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
    var dudlinessThreshold = 10
}

var selectionControls = SelectionControls()

enum CuratorStatus {
    case running, finished, chokedByDudliness
}

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

class Curator {
    let selector: Selector
    var numberOfGenerations = selectionControls.howManyGenerations
    var bestTestSubject: TSHandle?
    let testInputs = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
    var dudCounter = 0
    var promisingLines = [TSArchivableSubject]()
    var studBeingVetted: TSArchivableSubject?
    var aboriginalGenome: Genome
    
    let tsRelay: TSRelay
    let decoder = Decoder()
    let testSubjectFactory: TestSubjectFactory
    var studGenome: Genome
    var bestScoreEver = Double.infinity
    var bestGenomeEver = Genome()

    var testSubjects = TSTestGroup()
    
    init(starter: Genome? = nil, testSubjectFactory: TestSubjectFactory) {
        if let a = starter { self.aboriginalGenome = a }
        else {
//            let singleNeuronPassThroughPort = "N_A(true)_W(b[1]v[1])_B(b[0]v[0]_"
            let sag: Genome = { () -> Genome in
                var dag = Genome()
                for _ in 0..<5 {
                    dag += "L_"
                    for portNumber in 0..<3 {
                        dag += "N_"
                        for _ in 0..<portNumber { dag += "A(false)_" }
                        let granularity = 100000
                        let randomBia = Int.random(in: -granularity...granularity)
                        let randomBias = Double(randomBia) / Double(granularity)
                        dag += "A(true)_W(b[1]v[1])_B(b[\(randomBias.sTruncate())]v[0])_"
                    }
                }
                return dag
            }()
            
            self.aboriginalGenome = sag
            self.aboriginalGenome = RandomnessGenerator.generateRandomGenome()
        }
        
        testSubjectFactory.setDecoder(self.decoder)
        self.testSubjectFactory = testSubjectFactory
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
            precondition(vettee.tsHandle != winner,
                         "vettee is not being tested any more; he's being vetted!")
            
            // We have a new winner; archive the currently-being-vetted
            // guy, and now start vetting the new guy
            let fs = tsRelay.getFitnessScore(for: winner)
            let ffs = Utilities.notOptional(fs, "Something ain't right!")

//            for char in FTLearnZoeName.resultsArray {
//                print(String(char), terminator: "")
//            }
//            print()
            print("New record by \(winner): \(ffs)")
            self.promisingLines.append(vettee)
            self.studBeingVetted = nil      // In case it makes debugging easier
        }
        
        let stud = self.testSubjects.testSubjects[winner]!
        let genome = stud.genome
        guard let score = stud.getFitnessScore() else {
            return
        }

        self.bestScoreEver = score
        self.bestGenomeEver = genome

        let forArchival = TSArchivableSubject(tsHandle: winner, genome: genome, score: score)
        self.studBeingVetted = forArchival
    }
    
    func getMostInterestingTestSubject() -> NeuralNetProtocol {
        var mostInterestingGenome = String()
        
        if studGenome.count > 0 {
            mostInterestingGenome = studGenome
        } else if let bleedingEdge = studBeingVetted {
            mostInterestingGenome = bleedingEdge.genome
        } else if let reigningChampion = promisingLines.last {
            mostInterestingGenome = reigningChampion.genome
        } else if !bestGenomeEver.isEmpty {
            mostInterestingGenome = bestGenomeEver
        } else {
            mostInterestingGenome = aboriginalGenome
        }

        let _ = decoder.setInput(to: mostInterestingGenome).decode()
        let brain = Translators.t.getBrain()
        return brain
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
        guard let candidate = selector.select(from: generation, for: testInputs) else { return nil }

        // If I'm not vetting anyone yet (meaning, we just started with the aboriginal alone)
        guard let reigningChampion = self.studBeingVetted else { return candidate }

        precondition(candidate != reigningChampion.tsHandle, "Sanity check")

        guard let candidateScore = tsRelay.getFitnessScore(for: candidate) else {
            preconditionFailure("Generation returned a candidate that appears to have died during the test")
        }

        return (candidateScore < reigningChampion.score) ? candidate : reigningChampion.tsHandle
    }
    
    func track() -> CuratorStatus {
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
            if self.dudCounter < selectionControls.dudlinessThreshold { return false }

            self.dudCounter = 0

            if let zombie = self.promisingLines.popLast() {
                self.studBeingVetted = nil                  // This guy was too dudly, goodbye
                self.bestTestSubject = zombie.tsHandle      // Bring back his parent
                self.studGenome = zombie.genome
                self.studBeingVetted = zombie
                print("Dead end after \(selectionControls.dudlinessThreshold) tries; backing up to subject \(zombie.tsHandle)")
                return false                                // We haven't given up on anti-dudding yet
            }

            return true
        }
        
        let finalReport = { (_ completion: Bool) -> Void in
            let generationsTested = selectionControls.howManyGenerations - self.numberOfGenerations
            let message = completion ? "Complete:" : "Giving up after"
            print("\(message) \(generationsTested) generations")

            print("Best score from this run ~ \(self.bestScoreEver)\n")
            print("Genome: \(self.bestGenomeEver)")
        }

        if numberOfGenerations > 0 {
            defer { numberOfGenerations -= 1 }

            self.testSubjects.reset()   // New generation; kill off the old one
            let selected = select()

            trackDudness(selected)

            if self.bestTestSubject == nil
                { self.bestTestSubject = selected; return .running }
            
            if dudCounter == 0 {
                self.bestTestSubject = selected
                archivePromisingStud(bestTestSubject!)
                return .running
            }
            
            if isTooMuchDudness()// { finalReport(false); return .chokedByDudliness }
            {
                print("Trying new random genome")
                studGenome = RandomnessGenerator.generateRandomGenome()
            }
            
            return .running
        }
        
        finalReport(true)
        return .finished
    }
}
