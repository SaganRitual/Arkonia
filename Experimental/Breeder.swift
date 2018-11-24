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

class Breeder: BreederTestSubjectAPI {
    typealias Generation = [BreederTestSubject]
    
    public static var bb = Breeder()
    
    // The test subject classes may change these
    public static var howManyTestSubjectsPerGeneration = 75
    public static var howManyGenerations = 75

    private var currentProgenitor: BreederTestSubject!
    private var currentGeneration = Generation()
    private var aboriginalAncestorHasBestScore = true

    private let decoder = Decoder()
    private var testSubjectFactory: BreederTestSubjectFactory?
    
    var bestFitnessScore = Double.infinity
    var previousBestFitnessScore = Double.infinity
    private var fitnessTester: BreederFitnessTester!

    static let howManySenses = 5

    var previousWinners = [(Genome, Double, Double)]()
    var stagnantGenerationsCount = 0
    
    func getBestGenome() -> Genome {
        return self.currentProgenitor.genome!
    }
    
    func select(_ currentBestBrainSS: Int?) -> Int? {
        var bestBrainSS = currentBestBrainSS
        
        for (ss, testSubject) in zip(0..., self.currentGeneration) {
            guard let (score, resultString) = self.fitnessTester.administerTest(to: testSubject) else {
                continue
            }

            testSubject.fitnessScore = score

            if score < bestFitnessScore ||
                (score >= bestFitnessScore && aboriginalAncestorHasBestScore) {
                bestBrainSS = ss
                aboriginalAncestorHasBestScore = false

                print("\(resultString), score \(score.sTruncate())")
            }
        }

        return bestBrainSS
    }
    
    func thisGenerationSetANewRecord(_ bestBrainSS: Int) -> Bool {
        if currentGeneration[bestBrainSS].fitnessScore < self.bestFitnessScore {
            self.bestFitnessScore = currentGeneration[bestBrainSS].fitnessScore
            return true
        }

        return false
    }
    
    private static var progressReport = false
    public func breedAndSelect() -> Double {
        if testSubjectFactory == nil {
            fatalError("Can't do anything without a factory for test subjects")
        }
        
        aboriginalAncestorHasBestScore = true

        var bestBrainSS: Int?
        // First brain of the entire test
        if self.currentProgenitor == nil {
            bestBrainSS = setFirstBestScore()
        }
        
        let howMany = Breeder.howManyTestSubjectsPerGeneration
        self.currentGeneration = breedOneGeneration(howMany, from: self.currentProgenitor)
        
        // If all the subjects died during the test, we'll
        // need to back up to the previous progenitor. Same
        // for when a progenitor produces too many stagnant
        // generations in a row.
        var retreat = true
        
        if let best = select(bestBrainSS) {
//            let score = self.testSubjects[best].testScore
//            print("Test subject \(best) survived; score \(score); ", terminator: "")
            
            // At least one test subject in this generation
            // survived the test and produced results
            if thisGenerationSetANewRecord(best) {
//                print("new record \(score)")
                retreat = false
                registerNewRecordHolder(best)
            } else {
                retreat = trackStagnantGenerations()
//                print("Retreat? \(retreat)")
            }
        }
        
        if retreat { retreatToPreviousProgenitor() }

        previousBestFitnessScore = bestFitnessScore

        return bestFitnessScore.dTruncate()
    }
    
    func breedOneGeneration(_ howMany: Int, from: BreederTestSubject) -> Generation {
//        print(".", terminator: "")
        self.currentGeneration = Generation()
        
        for _ in 0..<howMany {
            if let newTestSubject = currentProgenitor.spawn() {
                if self.currentGeneration.contains(where: { testSubject in testSubject.genome == newTestSubject.genome } ) {
//                    print("_", terminator: "")
                } else {
                    self.currentGeneration.append(newTestSubject)
                }
            }
        }
        
        return self.currentGeneration
    }
    
    func setFirstBestScore() -> Int? {
        // Establish the aboriginal ancestor as the current
        // record holder.
        self.currentProgenitor = testSubjectFactory!.makeTestSubject()
        self.currentGeneration = [self.currentProgenitor]
        
        let bestBrainSS = select(nil)
        if bestBrainSS == nil {
            // If he failed, we need a new one. Leaving this part
            // unimplemented until I can get a handle on the scoring.
            fatalError("Aboriginal ancestor died; giving up")
        }
        
        return bestBrainSS
    }
    
    func retreatToPreviousProgenitor() {
//        print("Retreating")
        if previousWinners.isEmpty {
            self.bestFitnessScore = Double.infinity
            self.previousBestFitnessScore = Double.infinity
            print("Can't back up; starting over with aboriginal ancestor")
        } else {
            let (_, bestFitnessScore, previousBestScore) = previousWinners.removeLast()
            print("Backing up from \(bestFitnessScore.sTruncate()) to \(previousBestScore.sTruncate())")
            self.bestFitnessScore = bestFitnessScore
            self.previousBestFitnessScore = previousBestScore
        }
    }
    
    func trackInitialBestScore(bestBrainSS: Int?) {
        // This happens only once, at the beginning
        let genome = self.currentGeneration[0].genome!
        previousWinners.append((genome, bestFitnessScore, previousBestFitnessScore))
        self.currentProgenitor = self.currentGeneration[0]
        stagnantGenerationsCount = 0
    }
    
    func registerNewRecordHolder(_ bestBrainSS: Int?) {
        guard let best = bestBrainSS else { fatalError() }
        let genome = self.currentGeneration[best].genome!
        self.bestFitnessScore = self.currentGeneration[best].fitnessScore
        previousWinners.append((genome, bestFitnessScore, previousBestFitnessScore))
        self.currentProgenitor = self.currentGeneration[best]
        stagnantGenerationsCount = 0
//        print("!", terminator: "")
    }
    
    func trackStagnantGenerations() -> Bool {
//        print(stagnantGenerationsCount, terminator: "")
//        print("Track stagnant generation, count = \(stagnantGenerationsCount)")
        stagnantGenerationsCount += 1

        if stagnantGenerationsCount >= 5 {
            stagnantGenerationsCount = 0
            return true
        }
        
        return false
    }

    func setFitnessTester(_ tester: BreederFitnessTester) { self.fitnessTester = tester }
    
    func setTestSubjectFactory(_ factory: BreederTestSubjectFactory) -> Breeder {
        self.testSubjectFactory = factory
        return self     // for chaining
    }
}
