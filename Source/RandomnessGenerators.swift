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
import GameKit

enum RandomnessGenerator {
    static func generateRandomGene() -> String {
        // The map is so we can weight the gene types differently, so we
        // don't end up with one neuron per layer, or something silly like that.
        let geneSelector = [act : 10, bis : 5, fun : 5, hox: 0, lay : 2, neu : 3, wgt : 10]
        
        var weightedGeneSelector: [Character] = {
            var t = [Character]()
            for (geneType, weight) in geneSelector {
                for _ in 0..<weight { t.append(geneType) }
            }
            return t
        }()
        
        let geneSS = Int.random(in: 0..<weightedGeneSelector.count)
        let geneType = weightedGeneSelector[geneSS]

        switch geneType {
        case act: return "A(\(Bool.random()))"
        case bis: return "B(b[\(Double.random(in: -1...1).sTruncate())]v[\(Double.random(in: -1...1).sTruncate())])"
        case fun: return "F(\(RandomnessGenerator.getRandomOutputFunction()))"
        case lay: return "L"
        case neu: return "N"
        case wgt: return "W(b[\(Double.random(in: -1...1).sTruncate())]v[\(Double.random(in: -1...1).sTruncate())])"
        default: fatalError()
        }
    }
    
    static func generateRandomGenome(howManyGenes: Int = 75) -> Genome {
        var newGenome = Genome()
        for _ in 0..<howManyGenes { newGenome += generateRandomGene() }
        return newGenome
    }
    
    static func generateRandomTestSubject(howManyGenes: Int) -> TSHandle {
        fatalError()
    }
    
    static func getRandomOutputFunction() -> String {
        let blank = outputFunctions[Int.random(in: 0..<outputFunctions.count)].rawValue
        return blank
    }

    static let outputFunctions = [
        Translators.OutputFunctionName.limiter, Translators.OutputFunctionName.linear,
        Translators.OutputFunctionName.logistic, Translators.OutputFunctionName.tanh
    ]
}


// With deepest gratitude to Stack Overflow dude
// https://stackoverflow.com/users/2538939/code-different
// https://stackoverflow.com/a/44535176/1610473

class BellCurve {
    let summary: NSCountedSet
    let endOfRange: Int
    
    // I haven't been able to make it work with a
    // scale of 10; I think the generator doesn't like it,
    // but I haven't looked into it.
    let scale = 1.0
    let mean: Double
    let toPercentage: Double
    let shiftMedian = 50.0
    
    init() {
        self.mean = self.scale * shiftMedian
        self.toPercentage = self.scale * 100.0
        
        let arr = BellCurve.generateBellCurve(count: 100_000, mean: Int(self.mean), deviation: 16)
        let summary = NSCountedSet(array: arr)
        let endOfRange = BellCurve.getEndOfRange(summary)
        
        self.endOfRange = endOfRange
        self.summary = summary
    }
    
    static func generateBellCurve(count: Int, mean: Int, deviation: Int) -> [Int] {
        guard count > 0 else { return [] }
        
        let randomSource = GKARC4RandomSource()
        let randomDistribution = GKGaussianDistribution(randomSource: randomSource, mean: Float(mean), deviation: Float(deviation))
        
        // Clamp the result to within the specified range
        return (0..<count).map { _ in return randomDistribution.nextInt() }
    }
    
    static func getEndOfRange(_ summary: NSCountedSet) -> Int {
        var finalIndex = 0
        for indexer in 0..<summary.count { finalIndex += summary.count(for: indexer) }
        return finalIndex
    }
    
    func getDouble() -> Double {
        let reallyRandom = Int.random(in: 0..<endOfRange)
        var indexer = reallyRandom
        var normalRandom = 0
        
        for slotSS in 0..<summary.count {
            let slotValue = summary.count(for: slotSS)
            indexer -= slotValue
            
            if indexer < 0 { normalRandom = slotSS; break }
        }
        
        normalRandom -= Int(shiftMedian)
        
//        print("getDouble() -> \(reallyRandom), \(indexer), \(normalRandom)")
//        return 1.0 - (Double(normalRandom) / self.toPercentage)
        return (Double(normalRandom) - self.mean) / 100.0
    }
    
    func mutate(from value: Int) -> Int {
        let proposedValue = mutate(from: Double(value))
        return Int(proposedValue)
    }

    func mutate(from value: Double) -> Double {
        let percentage = getDouble()
        let moveMedianToZero = percentage - self.shiftMedian
        
        // Perhaps the reason we keep seeing so few survivors
        // is that the mutations are too big. See if we can
        // scale them down.
        let scale = 2.0
        return (value * (1 + (moveMedianToZero * scale))).dTruncate()
    }
    
    func mutate(from value: String) -> Double {
        return mutate(from: Double(value)!)
    }
}
