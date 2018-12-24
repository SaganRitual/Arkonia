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
    func accumulateBias(_ value: Double)
    func addActivator(_ active: Bool)
    func addWeight(_ value: ValueDoublet)
    func addWeight(_ baseline: Double, _ value: Double)
    func closeNeuron()
    func connectNeurons()
    func constructBottomLayer(howManyNeurons: Int, howManyInUpperLayer: Int)
    func constructTopLayer(howManyNeurons: Int)
    func endOfStrand()
    func newNeuron()
    func show(tabs: String, override: Bool)
}

protocol LayerOwnerProtocol {
    var layers: [Translators.Layer] { get set }

    func accumulateBias(_ value: Double)
    func addActivator(_ active: Bool)
    func addWeight(_ value: ValueDoublet)
    func addWeight(_ baseline: Double, _ value: Double)
    func closeLayer()
    func closeNeuron()
    func endOfStrand()
    func newLayer()
    func newNeuron()
    func setInputs(_ inputs: [Int])
    func show(tabs: String, override: Bool)

    func generateRandomSensoryInput() -> [Double]
}

protocol BrainOwnerProtocol: class {
    var reachedEndOfStrand: Bool { get set }

    func accumulateBias(_ value: Double)
    func addActivator(_ value: Bool)
    func addWeight(_ value: ValueDoublet)
    func addWeight(_ baseline: Double, _ value: Double)
    func closeBrain()
    func closeLayer()
    func closeNeuron()
    func endOfStrand()
    func getBrain() -> AKNet
    func getBrain() -> Translators.Brain
    func newLayer()
    func newNeuron()
    func reset()
    func show(tabs: String, override: Bool)
}

protocol NeuralNetProtocol: class, LayerOwnerProtocol { }
