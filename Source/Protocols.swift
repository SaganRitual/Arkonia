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

protocol NeuronOwnerProtocol: class {
    func addActivator(_ active: Bool)
    func addWeight(_ value: ValueDoublet)
    func addWeight(_ baseline: Double, _ value: Double)
    func closeNeuron()
    func connectNeurons()
    func constructBottomLayer(howManyNeurons: Int, howManyInUpperLayer: Int)
    func constructTopLayer(howManyNeurons: Int)
    func endOfStrand()
    func newNeuron()
    func setBias(_ value: ValueDoublet)
    func setBias(_ baseline: Double, _ value: Double)
    func setThreshold(_ value: ValueDoublet)
    func setThreshold(_ baseline: Double, _ value: Double)
    func show(tabs: String, override: Bool)
}

protocol LayerOwnerProtocol {
    var layers: [Translators.Layer] { get set }

    func addActivator(_ active: Bool)
    func addWeight(_ value: ValueDoublet)
    func addWeight(_ baseline: Double, _ value: Double)
    func closeLayer()
    func closeNeuron()
    func endOfStrand()
    func newLayer()
    func newNeuron()
    func setBias(_ value: ValueDoublet)
    func setBias(_ baseline: Double, _ value: Double)
    func setInputs(_ inputs: [Int])
    func setThreshold(_ value: ValueDoublet)
    func setThreshold(_ baseline: Double, _ value: Double)
    func show(tabs: String, override: Bool)
    func stimulate(sensoryInputs: [Double]) -> [Double?]

    func generateRandomSensoryInput() -> [Double]
}

protocol BrainOwnerProtocol: class {
    var reachedEndOfStrand: Bool { get set }

    func addActivator(_ value: Bool)
    func addWeight(_ value: ValueDoublet)
    func addWeight(_ baseline: Double, _ value: Double)
    func closeBrain()
    func closeLayer()
    func closeNeuron()
    func endOfStrand()
    func getBrain() -> NeuralNetProtocol
    func newLayer()
    func newNeuron()
    func reset()
    func setBias(_ value: ValueDoublet)
    func setBias(_ baseline: Double, _ value: Double)
    func setThreshold(_ value: ValueDoublet)
    func setThreshold(_ baseline: Double, _ value: Double)
    func show(tabs: String, override: Bool)
}

protocol SelectionTestSubjectFactory {
    func makeTestSubject(parentGenome: GenomeSlice, mutate: Bool) -> TSTestSubject?
}

protocol SelectionFitnessTester {
    func administerTest(to testSubject: TSTestSubject, for sensoryInput: [Double]) -> [Double]?
    func calculateFitnessScore(for testSubject: TSTestSubject, outputs: [Double]?)
    func getFitnessScore(for testSubject: TSTestSubject) -> Double?
}

protocol NeuralNetProtocol: class, LayerOwnerProtocol {
}

typealias TSArray = [TSTestSubject]
typealias TSArrayIndex = TSArray.Index
typealias TSArraySlice = ArraySlice<TSTestSubject>
