import Foundation

typealias TSHandle = Int
protocol LayerOwnerProtocol {
    var fitnessScore: Double? { get set }
    func stimulate(inputs: [Double]) -> Double?
}

typealias Brain = MockBrain

class MockBrain: LayerOwnerProtocol {
    var mockFitnessScore: Double?
    var fitnessScore: Double? {
        get { return mockFitnessScore } set { mockFitnessScore = newValue }
    }
    
    func stimulate(inputs: [Double]) -> Double? {
        // Test harness will set this before
        // administering the test
        return mockFitnessScore
    }
}

class TSTestSubject {
    static private var theFishNumber = 0
    
    private(set) var myFishNumber: Int
    private var brain: LayerOwnerProtocol?
    
    init() {
        self.myFishNumber = TSTestSubject.theFishNumber
        TSTestSubject.theFishNumber += 1
    }
    
    func getFitnessScore() -> Double? {
        guard let b = self.brain else { preconditionFailure("No brain, no score.") }
        return b.fitnessScore
    }
    
    func setBrain(_ brain: Brain) { self.brain = brain }

    func submitToTest(for sensoryInput: [Double]) -> Double? {
        guard let b = self.brain else { preconditionFailure("No brain, no test.") }
        return b.stimulate(inputs: sensoryInput)
    }
}

class TestSubjectFactory {
    func generateTestSubject() -> TSTestSubject { return TSTestSubject() }
}

class TSRelay {
    var testSubjects = [TSHandle : TSTestSubject]()
    var testSubjectFactory: TestSubjectFactory?
    
    func administerTest(to which: TSHandle, for inputs: [Double]) -> Double? {
        guard let ts = testSubjects[which] else { preconditionFailure() }
        return ts.submitToTest(for: inputs)
    }
    
    func getFitnessScore(for which: TSHandle) -> Double? {
        guard let ts = testSubjects[which] else { preconditionFailure() }
        return ts.getFitnessScore()
    }
    
    func makeTestSubject() -> TSHandle {
        guard let tsf = testSubjectFactory else
            { preconditionFailure("Can't make test subjects; no factory") }
        
        let testSubject = tsf.generateTestSubject()
        testSubjects[testSubject.myFishNumber] = testSubject
        return testSubject.myFishNumber
    }
    
    func setBrain(_ brain: Brain, for which: TSHandle) {
        guard let ts = testSubjects[which] else { preconditionFailure() }
        ts.setBrain(brain)
    }
    
    func setTestSubjectFactory(_ factory: TestSubjectFactory) {
        testSubjectFactory = factory
    }
}

class Generation {
    var bestTestSubject: TSHandle?
    var testSubjects = [TSHandle]()
    let tsRelay: TSRelay
    
    init(_ tsRelay: TSRelay) { self.tsRelay = tsRelay }
    
    func addTestSubject() -> TSHandle {
        let subject = tsRelay.makeTestSubject()
        testSubjects.append(subject)
        return subject
    }
    
    private func administerTest(to subject: TSHandle, for inputs: [Double]) -> Double? {
        guard let scoreForThisSubject =
            tsRelay.administerTest(to: subject, for: inputs) else { return nil }

        guard let bestTestSubject = self.bestTestSubject else {
            self.bestTestSubject = subject
            return scoreForThisSubject
        }
        
        guard let bestScore = tsRelay.getFitnessScore(for: bestTestSubject) else {
            preconditionFailure("Shouldn't have a best subject without a score")
        }
        
        if scoreForThisSubject < bestScore { self.bestTestSubject = subject }
        
        return scoreForThisSubject
    }
    
    private func select(for inputs: [Double]) -> TSHandle? {
        for testSubject in testSubjects {
            let _ = self.administerTest(to: testSubject, for: inputs)
        }
        
        return self.bestTestSubject
    }
    
    func submitToTest(with sensoryInput: [Double]) -> TSHandle? {
        return select(for: sensoryInput)
    }
}

let relay = TSRelay()
let generation = Generation(relay)
let testSubjectFactory = TestSubjectFactory()

relay.setTestSubjectFactory(testSubjectFactory)

for mockFitnessScore in 0..<10 {
    let ts = generation.addTestSubject()
    let b = Brain(); if ((mockFitnessScore / 2) * 2) == mockFitnessScore {
        b.mockFitnessScore = Double(10 - mockFitnessScore)
    }
    relay.setBrain(b, for: ts)
}

if let winner = generation.submitToTest(with: [1, 1, 1, 1, 1]) {
    print("Winner this generation is \(winner)")
} else {
    print("Everyone died!")
}
