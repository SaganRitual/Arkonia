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

enum RandomnessGenerator {
    static func generateRandomBrain(howManyGenes: Int = 100) -> LayerOwnerProtocol {
        let newGenome = generateRandomGenome(howManyGenes: howManyGenes)
        
        let decoder = Decoder()
        decoder.setInput(to: newGenome).decode()
        let brain = Translators.t.getBrain()
        return brain
    }

    static func generateRandomGene() -> String {
        // The map is so we can weight the gene types differently, so we
        // don't end up with one neuron per layer, or something silly like that.
        let geneSelector = [act : 10, bis : 5, lay : 1, neu : 3, thr : 5, wgt : 10]
        
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
        case act: return "A(\(Bool.random()))_"
        case bis: return "B(b[\(Double.random(in: -100...100).sTruncate())]v[\(Double.random(in: -100...100).sTruncate())])_"
        case fun: return RandomnessGenerator.getRandomOutputFunction()
        case lay: return layb
        case neu: return neub
        case thr: return "T(b[\(Double.random(in: -100...100).sTruncate())]v[\(Double.random(in: -100...100).sTruncate())])_"
        case wgt: return "W(b[\(Double.random(in: -100...100).sTruncate())]v[\(Double.random(in: -100...100).sTruncate())])_"
        default: fatalError()
        }
    }
    
    static func generateRandomGenome(howManyGenes: Int = 200) -> Genome {
        var newGenome = Genome()
        for _ in 0..<howManyGenes { newGenome += generateRandomGene() }
        return newGenome
    }
    
    static let outputFunctions = [
        Translators.OutputFunctionName.linear, Translators.OutputFunctionName.tanh,
        Translators.OutputFunctionName.logistic
    ]
    
    static func getRandomOutputFunction() -> String {
        return outputFunctions[Int.random(in: 0..<outputFunctions.count)].rawValue
    }
}
