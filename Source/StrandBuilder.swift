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

enum StrandBuilder {
    private static var B: String { return Utilities.B }
    private static var D: String { return Utilities.D }
    private static var F: String { return Utilities.F }
    private static var I: String { return Utilities.I }
    private static var L: String { return Utilities.L }
    private static var N: String { return Utilities.N }
    private static var b: String { return Utilities.b }
    private static var t: String { return Utilities.t }

    private static var maxLayersPerBrain: Int { return 10 }
    private static var maxNeuronsPerLayer: Int { return 10 }
    private static var maxActivatorsPerNeuron: Int { return 10 }
    
    private static func P(_ geneType: String, _ value: String) -> Gene { return geneType + "(" + value + ")" }
    private static func G(_ value: Bool) ->   Gene { return P(B, String(value)) }
    private static func G(_ value: Int) ->    Gene { return P(I, String(value)) }
    private static func G(_ value: Double) -> Gene { return P(D, String(value)) }
    private static func G(_ type: String) ->  Gene { return String(type) + "." }
    
    private static func S(_ bool: Bool) -> String { return G(bool) }
    private static func S(_ int: Int) -> String { return G(int) }
    private static func S(_ double: Double) -> String { let d = Double(truncating: NSNumber(value: double)); return G(d) }
    
    private static func buildNeuron(howManyActivators: Int) -> Strand {
        var strand = Strand()
        
        strand += G(howManyActivators) + G(howManyActivators)
        for _ in 0..<howManyActivators { strand.append(S(Bool.random())) }
        for _ in 0..<howManyActivators { strand.append(S(Double.random(in: -500...500))) }
        strand.append(S(Double.random(in: -500...500))) // Bias
        strand.append(S(Double.random(in: -500...500))) // Threshold
        
        return strand
    }
    
    private static func buildLayer(howManyNeurons: Int) -> Strand {
        var strand = Strand()
        
        for runningNeuronsCount in 0..<howManyNeurons {
            strand += G(N)
            if runningNeuronsCount > 0 {
                let activatorsCount = runningNeuronsCount
                strand += buildNeuron(howManyActivators: activatorsCount)
            }
        }
        
        return strand
    }
    
    private static func buildBrainStrand(maxLayers: Int) -> Strand {
        var singleStrand = Strand()
        for runningLayersCount in 0..<maxLayers {
            // Layer 0 has no neurons, 1 has 1, 2 has 2, etc, so the
            // max neurons count for a layer is the same as its number
            // of neurons.
            let neuronsCount = runningLayersCount
            
            singleStrand += G(L) + G(neuronsCount)
            if runningLayersCount > 0 {
                singleStrand += buildLayer(howManyNeurons: neuronsCount)
            }
        }
        return singleStrand
    }
    
    static func buildBrainStrands(howMany: Int) -> Strands {
        var singleStrand = Strand()
        for _ in 0..<howMany {
            let brainStrand = buildBrainStrand(maxLayers: maxLayersPerBrain)
            singleStrand.append(brainStrand)
        }
        
        return [singleStrand]
    }
}
