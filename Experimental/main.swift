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

protocol GenerationTestSubjectProtocol {
    func getFitnessScore() -> Double?
    func setFitnessScore(_ score: Double)
}

class GenerationTestSubject: GenerationTestSubjectProtocol {
    private var fitnessScore = 0.0

    func getFitnessScore() -> Double? { return self.fitnessScore }
    func setFitnessScore(_ score: Double) { self.fitnessScore = score }
}

protocol BrainStem {
    var fitnessScore: Double? { get set }
    func stimulate(inputs: [Double]) -> [Double]?
}

protocol NeuralNet: BrainStem & LayerOwnerProtocol {
    
}

class MockBrain: BrainStem {
    var mockFitnessScore: Double?
    var fitnessScore: Double? {
        get { return mockFitnessScore } set { mockFitnessScore = newValue }
    }
    
    func stimulate(inputs: [Double]) -> [Double]? {
        // Test harness will set this before
        // administering the test
        return [mockFitnessScore!]
    }
}

let relay = TSRelay()
let generation = Generation(relay)
let testSubjectFactory = TestSubjectFactory()

for mockFitnessScore in 0..<10 {
    let ts = generation.addTestSubject()
    let b = MockBrain(); if ((mockFitnessScore / 2) * 2) == mockFitnessScore {
        b.mockFitnessScore = Double(10 - mockFitnessScore)
    }
    relay.setBrain(b, for: ts)
}

if let winner = generation.submitToTest(with: [1, 1, 1, 1, 1]) {
    print("Winner this generation is \(winner)")
} else {
    print("Everyone died!")
}
