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

typealias Gene = String
typealias Strand = String
typealias Strands = [Strand]

let D = "D", L = "L", I = "I", N = "N", F = "F", B = "B", b = "b", t = "t"

var runningActivatorsCount = 0
var runningNeuronsCount = 0
var runningLayersCount = 1

let maxLayersPerBrain = 10
let maxNeuronsPerLayer = 10
let maxActivatorsPerNeuron = 10

func G(_ value: Bool) -> Gene { return B + "(" + String(value) + ")" }
func G(_ value: Int) -> Gene { return I + "(" + String(value) + ")" }
func G(_ value: Double) -> Gene { return D + "(" + String(value) + ")" }
func G(_ type: String) -> Gene { return String(type) + "." }

func S(_ bool: Bool) -> String { return G(bool) }
func S(_ int: Int) -> String { return G(int) }
func S(_ double: Double) -> String { let d = Double(truncating: NSNumber(value: double)); return G(d) }

// L.I(0)
// L.I(1)N.I(0)I(0)D(0)D(0)
// L.I(1)N.I(1)I(1)D(42.42)D(42.42)
// L.I(1)N.I(2)I(2)D(42.42)D(42.42)D(43.42)D(43.42)

func buildNeuron(howManyActivators: Int) -> Strand {
    var strand = Strand()

    strand += G(howManyActivators) + G(howManyActivators)
    for _ in 0..<howManyActivators { strand.append(S(Bool.random())) }
    for _ in 0..<howManyActivators { strand.append(S(Double.random(in: -500...500))) }
    strand.append(S(Double.random(in: -500...500))) // Bias
    strand.append(S(Double.random(in: -500...500))) // Threshold
    
    return strand
}

func buildLayer(howManyNeurons: Int) -> Strand {
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

func buildBrainStrand(maxLayers: Int) -> Strand {
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

func main() {
    var singleStrand = Strand()
    let brainsCount = 1
    for _ in 0..<brainsCount {
        let brainStrand = buildBrainStrand(maxLayers: maxLayersPerBrain)
        singleStrand.append(brainStrand)
    }
    
    print(singleStrand)
}

main()
