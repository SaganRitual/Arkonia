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

    private var currentProgenitor: BreederTestSubject!
    private var currentGeneration = Generation()
    private var aboriginalAncestorHasBestScore = true

    private let decoder = Decoder()
    private var testSubjectFactory: BreederTestSubjectFactory?
    
    var bestFitnessScore = Double.infinity
    private var fitnessTester: BreederFitnessTester!

    static let howManySenses = 5

    var testSubjects = Generation()
    
    func select(_ currentBestBrainSS: Int?) -> Int? {
        var bestBrainSS = currentBestBrainSS
        
        for (ss, testSubject) in zip(0..., self.currentGeneration) {
            guard let score = self.fitnessTester.administerTest(to: testSubject) else {
                print("Subject \(ss) did not survive the test")
                continue
            }

            if score < bestFitnessScore ||
                (score > bestFitnessScore && aboriginalAncestorHasBestScore) {
                bestBrainSS = ss; bestFitnessScore = score
                aboriginalAncestorHasBestScore = false
            }
        }
        
        return bestBrainSS
    }
    
    public func breedAndSelect() -> Double {
        guard let testSubjectFactory = self.testSubjectFactory else {
            fatalError("Can't do anything without a factory for test subjects")
        }
        
        var bestBrainSS: Int? = nil
        var ancestorTakesTheScore = false

//        let oldBestFitnessScore = bestFitnessScore
        if self.currentProgenitor == nil {
            self.currentProgenitor = testSubjectFactory.makeTestSubject()
            self.currentGeneration = [self.currentProgenitor]
            
            // Only for reporting purposes, so it doesn't look like
            // offspring[0] won the first contest by tying with the
            // progenitor. And this will happen only on the first time
            // through, when we get a nil progenitor.
            ancestorTakesTheScore = (select(bestBrainSS) != nil)
        }
        
        self.testSubjects = breedOneGeneration(50, from: self.currentProgenitor)
        bestBrainSS = select(bestBrainSS)
        
        if let best = bestBrainSS, !ancestorTakesTheScore {
            let c = self.currentGeneration[best] as! BreederTestZoeBrain
            print("Offspring \(best), fishID = \(c.myFishNumber) wins: score \(self.bestFitnessScore)")
            print(c.genome)
        } else {
            print("Progenitor holds title: score \(self.bestFitnessScore)")
//
//            if bestFitnessScore == oldBestFitnessScore {
//                let c = self.currentGeneration[0] as! BreederTestZoeBrain
//                print("Survived but lost")
//                print(c.genome)
//            }
        }

        return bestFitnessScore.dTruncate()
    }
    
    func breedOneGeneration(_ howMany: Int, from: BreederTestSubject) -> Generation {
        self.currentGeneration = Generation()
        
        for _ in 0..<howMany {
            let newTestSubject = currentProgenitor.spawn()
            self.currentGeneration.append(newTestSubject)
        }
        
        return self.currentGeneration
    }
    
    static func getSensoryInput() -> [Double] {
        var inputs = [Double]()
        for _ in 0..<howManySenses {
            inputs.append(Double.random(in: -100...100).dTruncate())
        }
        
        return inputs
    }

    func setFitnessTester(_ tester: BreederFitnessTester) { self.fitnessTester = tester }
    
    func setTestSubjectFactory(_ factory: BreederTestSubjectFactory) -> Breeder {
        self.testSubjectFactory = factory
        return self     // for chaining
    }
}
