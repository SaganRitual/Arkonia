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

class Breeder {
    public static var bb = Breeder()
    
    typealias GenoPheno = (Genome, BrainProtocol)
    typealias Generation = [GenoPheno]
    
    private var currentProgenitorGenome: Genome!
    private var currentGeneration = [(Genome, BrainProtocol)]()

    private let decoder = Decoder()
    
    var currentProgenitorBrain: BrainProtocol!
    var bestFitnessScore = Int.max
    
    let zName = "Zoe Bishop"
    let uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ "
    let lowercase = "abcdefghijklmnopqrstuvwxyz "

    static let howManySenses = 5
    
    func setProgenitor(_ progenitor: Genome? = nil) {
        if let p = progenitor {
            decoder.setInput(to: p).decode()
            currentProgenitorGenome = p
        } else {
            currentProgenitorGenome = Breeder.generateRandomGenome()
        }
    }
    
    func breedOneGeneration(_ howMany: Int, from: Genome) {
        self.currentGeneration = Generation()

        for _ in 0..<howMany {
            _ = Mutator.m.setInputGenome(currentProgenitorGenome).mutate()
            let mutatedGenome = Mutator.m.convertToGenome()
            decoder.setInput(to: mutatedGenome).decode()
            let brain = Expresser.e.getBrain()
            self.currentGeneration.append((mutatedGenome, brain))
        }
    }
    
    static func getSensoryInput() -> [Double] {
        var inputs = [Double]()
        for _ in 0..<howManySenses {
            inputs.append(Double.random(in: -100...100).dTruncate())
        }
        
        return inputs
    }
    
    static func generateRandomGene() -> String {
        // The map is so we can weight the gene types differently, so we
        // don't end up with one neuron per layer, or something silly like that.
        let geneSelector = [A : 10, L : 1, N : 3, W : 10, b : 8, t : 8]

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
        case A: return "A(\(Bool.random()))."
        case L: return "L."
        case N: return "N."
        case W: return "W(\(Double.random(in: -100...100).sTruncate()))."
        case b: return "b(\(Double.random(in: -100...100).sTruncate()))."
        case t: return "t(\(Double.random(in: -100...100).sTruncate()))."
        default: fatalError()
        }
    }
    
    static func generateRandomGenome(howManyGenes: Int = 100) -> Genome {
        var newGenome = Genome()
        for _ in 0..<howManyGenes { newGenome += Breeder.generateRandomGene() }
        return newGenome
    }
    
    static func makeRandomBrain(howManyGenes: Int = 100) -> BrainProtocol {
        let newGenome = generateRandomGenome(howManyGenes: howManyGenes)
        
        let decoder = Decoder()
        decoder.setInput(to: newGenome).decode()
        let brain = Expresser.e.getBrain()
        return brain
    }
    
    func getFitnessScore(for: [Double]) -> Int {
        var scoreForTheseOutputs = 0

        var matchIndex: String.Index!
        var whichCase = uppercase

        for character in zName {
            if character == " " {
                whichCase = "ADisgustingHackThatIShouldBePuni shed for"
                matchIndex = whichCase.firstIndex(of: character)!
            } else if String().isUppercase(character) {
                matchIndex = uppercase.firstIndex(of: character)!
                whichCase = uppercase
            } else {
                matchIndex = lowercase.firstIndex(of: character)!
                whichCase = lowercase
            }
            
            let s = whichCase.distance(from: whichCase.startIndex, to: matchIndex)
            scoreForTheseOutputs += s
        }
        
        return scoreForTheseOutputs
    }
    
    func lambda(childGenome: Genome, brain: BrainProtocol) -> Bool {
        let sensoryInput: [Double] = [1, 1, 1, 1, 1]
        let outputs = brain.stimulate(sensoryInput: sensoryInput)
        print(outputs)
        var foundNewWinner = false
        let fs = getFitnessScore(for: outputs)
        if fs < bestFitnessScore {
            foundNewWinner = true
            bestFitnessScore = fs
            self.currentProgenitorGenome = childGenome
            self.currentProgenitorBrain = brain
            
            var zIndex = zName.startIndex
            for output in outputs {
                let zSlice = zName[zIndex...]
                let zChar = zSlice.first!
                
                let chopped = Int(output.remainder(dividingBy: 27.0).rounded())
                let isUppercase = String().isUppercase(zChar)
                let whichCase = isUppercase ? uppercase : lowercase
                let characterIndex = whichCase.index(whichCase.startIndex, offsetBy: chopped)
                print(whichCase[characterIndex], terminator: "")
                
                zIndex = zName.index(after: zIndex)
            }
            print("\nBest score so far: \(bestFitnessScore)")
        }
        
        return foundNewWinner
    }

    var testBrains = [Genome]()
    public func selectFromCurrentGeneration() -> [Genome] {
        let progenitorGenome = self.currentProgenitorGenome
        let winnerOfThisGeneration = progenitorGenome
        
        guard let w = winnerOfThisGeneration else { fatalError() }
        
        self.testBrains = [Genome]()
        
        decoder.setInput(to: w).decode()
        currentProgenitorBrain = Expresser.e.getBrain()
        testBrains.append(currentProgenitorGenome)
        
        var bestBrainSS = -1
        _ = lambda(childGenome: currentProgenitorGenome, brain: currentProgenitorBrain)
        
        for (ss, (childGenome, brain)) in zip(0..., self.currentGeneration) {
            if lambda(childGenome: childGenome, brain: brain) {
                bestBrainSS = ss
            }
        }
        
        if bestBrainSS == -1 {
            print("Progenitor wins: score \(self.bestFitnessScore)")
        } else {
            print("Offspring \(bestBrainSS) wins: score \(self.bestFitnessScore)")
        }

        return testBrains
    }
}
