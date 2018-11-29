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

enum CuratorStatus {
    case chokedByDudliness, finished, paused, results(TSHandle?), running
}

enum SelectionStatus {
    case paused
    case running(TSHandle?)
}

class TSTestGroup {
    var testSubjects = [TSHandle : TSTestSubject]()
    
    func reset() { testSubjects.removeAll() }
    
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
    var status_ = CuratorStatus.running
    var status: CuratorStatus {
        get {
            print("get status -> \(status_)", to: &Log.L)
            return status_
        }
        
        set {
            print("status = \(status_)", to: &Log.L)
            status_ = newValue
        }
    }
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
    var generation: Generation
    
    static private func makeOneLayer(_ protoGenome_: Genome, _ ctNeurons: Int) -> Genome {
        var protoGenome = protoGenome_ + "L_"
        
        for portNumber in 0..<ctNeurons {
            protoGenome += "N_"
            for _ in 0..<portNumber { protoGenome += "A(false)_" }
            let randomBias = Double.random(in: -1...1).sTruncate()
            let randomWeight = Double.random(in: -1...1).sTruncate()
            protoGenome += "A(true)_F(tanh)_W(b[\(randomWeight)]v[\(randomWeight)])_B(b[\(randomBias)]v[\(randomBias)])_"
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
        self.generation = Generation(tsRelay, testSubjects: testSubjects)
        guard let aboriginalAncestor =
            try? testSubjectFactory.makeTestSubject(genome: self.aboriginalGenome, mutate: false)
            else { return nil }
        
        testSubjects[aboriginalAncestor.myFishNumber] = aboriginalAncestor

        let _ = generation.addTestSubject(aboriginalAncestor.myFishNumber)
        let referenceTime = DispatchTime.now().uptimeNanoseconds
        
        if case let CuratorStatus.results(candidate) =
            generation.submitToTest(with: testInputs, referenceTime: referenceTime) {
            self.bestTestSubject = candidate
        }
        
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
        if case CuratorStatus.paused = self.status {
            print("makeGeneration() exits for pause mode", to: &Log.L)
            return self.generation
        }
        
        print("makeGeneration() makes a generation", to: &Log.L)

        self.generation = Generation(tsRelay, testSubjects: testSubjects)

        let howManySubjectsPerGeneration = (thisMany == nil) ?
            selectionControls.howManySubjectsPerGeneration : thisMany!
        
        for _ in 0..<howManySubjectsPerGeneration {
            let testSubject = try testSubjectFactory.makeTestSubject(genome: self.studGenome, mutate: mutate)
            testSubjects[testSubject.myFishNumber] = testSubject
            generation.addTestSubject(testSubject.myFishNumber)
        }
        
        return generation
    }
    
    func select() -> CuratorStatus {
        guard let generation = try? makeGeneration() else { return .results(nil) }
        
        let referenceTime = DispatchTime.now().uptimeNanoseconds

        // At least one survived in this generation
        var c: TSHandle?
        let s = selector.select(from: generation, for: testInputs, referenceTime: referenceTime)
        print("C calls S.select() -> \(s)", to: &Log.L)
        if case CuratorStatus.results(let r) = s, r == nil { return .results(nil) }
        if case CuratorStatus.paused = s { return .paused }

        switch s {
        case CuratorStatus.chokedByDudliness: fallthrough
        case CuratorStatus.finished:          fallthrough
        case CuratorStatus.running:           fatalError("Only the Curator can decide these things")
        case CuratorStatus.paused:            print("C.select() -> paused", to: &Log.L); return CuratorStatus.paused
        case CuratorStatus.results(let t):    c = t
        }
        
        precondition(c != nil)
        let candidate = c!

        // If I'm not vetting anyone yet (meaning, we just started with the aboriginal alone)
        guard let reigningChampion = self.studBeingVetted else { return .results(candidate) }

        precondition(candidate != reigningChampion.tsHandle, "Sanity check")

        guard let candidateScore = tsRelay.getFitnessScore(for: candidate) else {
            preconditionFailure("Generation returned a candidate that appears to have died during the test")
        }

        return (candidateScore < (reigningChampion.fitnessScore ?? Double.infinity))
                ? CuratorStatus.results(candidate) : CuratorStatus.results(reigningChampion.tsHandle)
    }
    
    func track(referenceTime: UInt64) -> CuratorStatus {
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
            print("nog: \(self.status)", to: &Log.L);
            defer { numberOfGenerations -= 1 }

            if case CuratorStatus.running = self.status {
                self.testSubjects.reset()   // New generation; kill off the old one
            }
            
            let s = select()
            var selected: Int?
            switch s {
            case .results(let ss): selected = ss; break
            case .paused:          self.status = .paused; print("nog2: \(selected ?? -42)", to: &Log.L); return .paused
            default: fatalError()
            }

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
