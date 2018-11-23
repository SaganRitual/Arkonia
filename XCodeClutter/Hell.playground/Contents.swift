import Foundation

protocol TestSubjectProtocol {
    var fitnessScore: Double? { get set }
    var idNumber: Int { get }

    func submitToTest(for inputs: [Double]) -> Double?
}

class BreederTestSubject: TestSubjectProtocol {
    var fitnessScore: Double? = nil
    let idNumber: Int
    
    init() { idNumber = 0 }
    
    func submitToTest(for inputs: [Double]) -> Double? { return nil }
    
    static func ==(_ lhs: BreederTestSubject, _ rhs: BreederTestSubject) -> Bool {
        return lhs.idNumber == rhs.idNumber
    }
}

var numberOfTestSubjectsPerGeneration = 0
let bigTheNumberOfGenerations = 5

func makeRandomTestSubject() -> BreederTestSubject { return BreederTestSubject() }


class Custodian {
    let selector = Selector()
    var numberOfGenerations = bigTheNumberOfGenerations
    var bestTestSubject: BreederTestSubject?
    let testInputs = [1.0, 1.0, 1.0, 1.0]
    var dudCounter = 0
    var promisingLines: [BreederTestSubject]?
    var aboriginalTestSubject: BreederTestSubject?
    
    init(_ aboriginalTestSubject: BreederTestSubject? = nil) {
        if let a = aboriginalTestSubject { self.aboriginalTestSubject = a }
        else { self.aboriginalTestSubject = makeRandomTestSubject() }
        
        // Get the aboriginal's fitness score as the
        // first one to beat. Also make sure the aboriginal
        // survives the test.
        let g = Generation()
        g.addTestSubject(self.aboriginalTestSubject!)
        g.submitToTest(for: testInputs)
        
        self.bestTestSubject =  g.bestTestSubject
    }
    
    func makeGeneration(from ancestor: BreederTestSubject) -> Generation {
        return Generation()
    }

    func select() -> BreederTestSubject? {
        let g = makeGeneration(from: self.bestTestSubject!)
        
        guard let candidate = selector.select(from: g, for: testInputs) else { return nil }

        if let myBest = self.bestTestSubject {
            if candidate.fitnessScore! < myBest.fitnessScore! {
                self.bestTestSubject = candidate
            }
        } else {
            self.bestTestSubject = candidate
        }
        
        return self.bestTestSubject
    }
    
    func track() {
        while numberOfGenerations > 0 {
            defer { numberOfGenerations -= 1 }
            
            if let survivor = select() {
                if let myCurrentBest = self.bestTestSubject {
                    if survivor == myCurrentBest { dudCounter += 1 }
                    else { dudCounter = 0 }
                } else { self.bestTestSubject = survivor }
            } else { dudCounter += 1 }  // The whole generation died
            
            if dudCounter == 0 {
                if promisingLines == nil { promisingLines = [] }
                promisingLines!.append(bestTestSubject!)
            } else if dudCounter >= 5 {
                if var p = promisingLines, !p.isEmpty {
                    self.bestTestSubject = p.popLast()
                } else {
                    print("Even the aboriginal was a dud")
                    break
                }
            }
        }
    }
}

class Selector {
    var bestTestSubject: BreederTestSubject?
    var generations = [Generation]()
    var testInputs = [Double]()
    var generationCounter = 0
    
    private func administerTest(to generation: Generation, for inputs: [Double]) -> BreederTestSubject? {
        guard let bestSubjectOfGeneration = generation.submitToTest(for: inputs) else { return nil }
        guard let bestScoreOfTheGeneration = bestSubjectOfGeneration.fitnessScore else { preconditionFailure() }
        
        if let b = self.bestTestSubject {
            if let s = b.fitnessScore { if bestScoreOfTheGeneration < s { self.bestTestSubject = b } }
            else { preconditionFailure() }
        } else {
            self.bestTestSubject = bestSubjectOfGeneration
        }

        return self.bestTestSubject
    }
    
    func select(from generation: Generation, for inputs: [Double]) -> BreederTestSubject? {
        _ = administerTest(to: generation, for: inputs)
        return self.bestTestSubject
    }
}

class Generation {
    var bestTestSubject: BreederTestSubject?
    var testSubjects = [BreederTestSubject]()
    
    func addTestSubject(_ subject: BreederTestSubject) { testSubjects.append(subject) }
    
    private func administerTest(to subject: BreederTestSubject, for inputs: [Double]) -> Double? {
        guard let scoreForThisSubject = subject.submitToTest(for: inputs) else { return nil }

        if let b = self.bestTestSubject {
            if let s = b.fitnessScore { if scoreForThisSubject < s { self.bestTestSubject = b } }
            else { preconditionFailure() }
        } else {
            self.bestTestSubject = subject
        }

        subject.fitnessScore = scoreForThisSubject
        return scoreForThisSubject
    }
    
    private func select(for inputs: [Double]) -> BreederTestSubject? {
        for testSubject in testSubjects {
            administerTest(to: testSubject, for: inputs)
        }
        
        return self.bestTestSubject
    }
    
    func submitToTest(for inputs: [Double]) -> BreederTestSubject? {
        return select(for: inputs)
    }
}
