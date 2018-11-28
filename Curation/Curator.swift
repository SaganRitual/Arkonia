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
    var howManyMotorNeurons = "Zoe Bishop".count
    var howManyGenerations = 30000
    var howManyGenes = 200
    var howManySubjectsPerGeneration = 200
    var theFishNumber = 0
    var dudlinessThreshold = 5
}

var selectionControls = SelectionControls()

// With deepest gratitude to Stack Overflow dude
// https://stackoverflow.com/users/3441734/user3441734
// https://stackoverflow.com/a/44541541/1610473
class Log: TextOutputStream {

    static var L = Log()
    
    var fm = FileManager.default
    let log: URL
    var handle: FileHandle?
    
    init() {
        log = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("roblog.txt")
        if let h = try? FileHandle(forWritingTo: log) {
            h.seekToEndOfFile()
            self.handle = h
        } else {
            print("Couldn't open logfile")
        }
    }
    
    deinit { handle?.closeFile() }

    func write(_ string: String) {
        #if false
        return
        #else

        if let h = self.handle {
            h.write(string.data(using: .utf8)!)
        } else {
            try? string.data(using: .utf8)?.write(to: log)
        }
        #endif
    }
}

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
    var fitnessScore: Double?
    var fitnessReport: String?
    
    init(tsHandle: TSHandle, genome: Genome, brain: BrainStem) {
        self.tsHandle = tsHandle; self.genome = genome;
        
        self.fitnessScore = brain.fitnessScore; self.fitnessReport = brain.fitnessReport
    }
}

class Curator {
    let selector: Selector
    var numberOfGenerations = selectionControls.howManyGenerations
    var bestTestSubject: TSHandle?
    let testInputs = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
    var dudCounter = 0
    var promisingLines = [TSArchivableSubject]()
    var studBeingVetted: TSArchivableSubject?
    var aboriginalGenome: Genome
    
    let tsRelay: TSRelay
    let decoder = Decoder()
    let testSubjectFactory: TestSubjectFactory
    var studGenome: Genome
    var bestScoreEver = Double.infinity
    var bestReportEver = String()
    var bestGenomeEver = Genome()

    var testSubjects = TSTestGroup()
    
    static private func makeOneLayer(_ protoGenome_: Genome, _ ctNeurons: Int) -> Genome {
        var protoGenome = protoGenome_ + "L_"
        
        for portNumber in 0..<ctNeurons {
            protoGenome += "N_"
            for _ in 0..<portNumber { protoGenome += "A(false)_" }
            let randomBias = Double.random(in: -1...1).sTruncate()
            let randomWeight = Double.random(in: -1...1).sTruncate()
            protoGenome += "A(true)_F(limiter)_W(b[\(randomWeight)]v[\(randomWeight)])_B(b[\(randomBias)]v[\(randomBias)])_"
        }
        
        return protoGenome
    }
    
    static func getPromisingStarterGenome() -> Genome {
        var dag = Genome()
        for _ in 0..<3 { dag = makeOneLayer(dag, 5) }
        dag = makeOneLayer(dag, selectionControls.howManyMotorNeurons)
        return dag
    }
    
    init?(starter: Genome? = nil, testSubjectFactory: TestSubjectFactory) {
        if let a = starter { self.aboriginalGenome = a }
        else { self.aboriginalGenome = Curator.getPromisingStarterGenome() }
        
        testSubjectFactory.setDecoder(self.decoder)
        self.testSubjectFactory = testSubjectFactory
        self.tsRelay = TSRelay(testSubjects)
        self.selector = Selector(tsRelay, testGroup: testSubjects)
        
        // Get the aboriginal's fitness score as the
        // first one to beat. Also good to make sure the aboriginal
        // survives the test.
        let generation = Generation(tsRelay, testSubjects: testSubjects)
        guard let aboriginalAncestor =
            try? testSubjectFactory.makeTestSubject(genome: self.aboriginalGenome, mutate: false)
            else { return nil }
        
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

            print("Found '\(self.bestReportEver)'")

            print("New record by \(winner): \(ffs)")
            self.promisingLines.append(vettee)
            self.studBeingVetted = nil      // In case it makes debugging easier
        }
        
        let stud = self.testSubjects.testSubjects[winner]!
        let genome = stud.genome
        guard let score = stud.getFitnessScore(), let report = stud.getFitnessReport() else {
            return
        }

        self.bestReportEver = report
        self.bestScoreEver = score
        self.bestGenomeEver = genome
        
        print("The following genome scored \(bestScoreEver) with '\(report)'", genome, to: &Log.L)
        
        let brain = tsRelay.getBrain(of: winner)!

        let forArchival = TSArchivableSubject(tsHandle: winner, genome: genome, brain: brain)
        self.studBeingVetted = forArchival
    }
    
    func getMostInterestingTestSubject() throws -> NeuralNetProtocol {
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

        let _ = try decoder.setInput(to: mostInterestingGenome).decode()
        let brain = Translators.t.getBrain()
        return brain
    }

    func makeGeneration(mutate: Bool = true, force thisMany: Int? = nil) throws -> Generation {
        let howManySubjectsPerGeneration = (thisMany == nil) ?
            selectionControls.howManySubjectsPerGeneration : thisMany!
        
        let generation = Generation(tsRelay, testSubjects: testSubjects)
        
        for _ in 0..<howManySubjectsPerGeneration {
            let testSubject = try testSubjectFactory.makeTestSubject(genome: self.studGenome, mutate: mutate)
            testSubjects[testSubject.myFishNumber] = testSubject
            generation.addTestSubject(testSubject.myFishNumber)
        }
        
        return generation //Generation(tsRelay, testSubjects: testSubjects)
    }
    
    func select() -> TSHandle? {
        guard let generation = try? makeGeneration() else { return nil }
        
        // At least one survived in this generation
        guard let candidate = selector.select(from: generation, for: testInputs) else { return nil }

        // If I'm not vetting anyone yet (meaning, we just started with the aboriginal alone)
        guard let reigningChampion = self.studBeingVetted else { return candidate }

        precondition(candidate != reigningChampion.tsHandle, "Sanity check")

        guard let candidateScore = tsRelay.getFitnessScore(for: candidate) else {
            preconditionFailure("Generation returned a candidate that appears to have died during the test")
        }

        return (candidateScore < (reigningChampion.fitnessScore ?? Double.infinity))
                ? candidate : reigningChampion.tsHandle
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
            print("Best genome: \(self.bestGenomeEver)")

            print("Best score from this run ~ \(self.bestScoreEver), best attempt = \(self.bestReportEver)\n")
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
                studGenome = Curator.getPromisingStarterGenome()
//                studGenome = RandomnessGenerator.generateRandomGenome()
//                let endIndex = studGenome.index(studGenome.startIndex, offsetBy: 50)
//                let ctRemainingCharacters = studGenome.distance(from: endIndex, to: studGenome.endIndex)
//                print("Reseeding with \(studGenome[..<endIndex])...(\(ctRemainingCharacters) more characters)")
            }
            
            return .running
        }
        
        finalReport(true)
        return .finished
    }
}
