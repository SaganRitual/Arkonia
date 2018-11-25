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

protocol NeuralNetProtocol: BrainStem & LayerOwnerProtocol {
    
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

let pointOhOneSix =  "L_N_A(true)_W(b[0.85008]v[0.85008])_N_A(true)_W(b[0.91789]v[1.032])_N_A(false)_W(b[1.0261]v[1.08621])_N_A(true)_W(b[1]v[1])_N_A(true)_W(b[0.97173]v[1.01098])_"
let pointOhOhEight = "L_N_A(true)_W(b[0.81439]v[0.84956])_N_A(false)_W(b[1]v[1])_N_A(true)_W(b[0.98591]v[1.01923])_N_A(true)_W(b[0.97715]v[3.41965])_N_A(true)_W(b[1]v[1])_"

var testSubjects = TSTestGroup()
let decoder = Decoder()
let relay = TSRelay(testSubjects)
let callbacks = Custodian.Callbacks()
let testSubjectFactory = TestSubjectFactory(relay, decoder: decoder, callbacks: callbacks)
let fitnessTester = TestSubjectFitnessTester(callbacks: callbacks)
let custodian = Custodian(starter: nil, callbacks: callbacks)

custodian.track()

