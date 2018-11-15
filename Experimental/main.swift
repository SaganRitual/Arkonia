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

func main() {
    // The map is so we can weight the gene types differently, so we
    // don't end up with one neuron per layer, or something silly like that.
    let geneSelector = [A : 5, L : 1, N : 3, W : 5, b : 4, t : 4]
    
    let inputGenome: Genome = {
        var workingGenome = Genome()
        var weightedGeneSelector: [Character] = {
            var t = [Character]()
            for (geneType, weight) in geneSelector {
                for _ in 0..<weight { t.append(geneType) }
            }
            return t
        }()

        for _ in 0..<100 {
            let geneSS = Int.random(in: 0..<weightedGeneSelector.count)
            let geneType = weightedGeneSelector[geneSS]

            switch geneType {
            case A: workingGenome += "A(\(Bool.random()))."
            case L: workingGenome += "L."
            case N: workingGenome += "N."
            case W: workingGenome += "W(\(Double.random(in: -100...100).truncate()))."
            case b: workingGenome += "b(\(Double.random(in: -100...100).truncate()))."
            case t: workingGenome += "t(\(Double.random(in: -100...100).truncate()))."
            default: fatalError()
            }
        }

        return workingGenome
    }()
    
    print(inputGenome)
    
    let decoder = Decoder(inputGenome: inputGenome)
    decoder.decode()
    decoder.expresser.getBrain().show()
}

main()
