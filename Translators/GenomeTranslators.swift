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

//// Genome display during decode
//class Translators: BrainOwnerProtocol {
//    static let t = Translators()
//
//    static var numberOfSenses = 5
//    static var numberOfMotorNeurons = 5// "Zoe Bishop".count
//
//    func setBias(_ value: ValueDoublet) { print("B(\(value))).", terminator: "") }
//    func setBias(_ baseline: Double, _ value: Double)
//        { setBias(ValueDoublet(baseline, value)) }
//
//    func setThreshold(_ value: ValueDoublet) { print("T(\(value)).", terminator: "") }
//    func setThreshold(_ baseline: Double, _ value: Double)
//        { setThreshold(ValueDoublet(baseline, value)) }
//
//    var reachedEndOfStrand: Bool = true
//
//    func addActivator(_ active: Bool) { print("\n\t\t\tA(\(String(active))).", terminator: "") }
//
//    func addWeight(_ value: ValueDoublet) {  print("W(\(value)).", terminator: "") }
//    func addWeight(_ baseline: Double, _ value: Double)
//        { addWeight(ValueDoublet(baseline, value)) }
//
//    func closeBrain() {  }
//    func closeLayer() { print() }
//    func closeNeuron() { print() }
//
//    func connectLayers() { }
//
//    func endOfStrand() { reachedEndOfStrand = true; print() }
//
//    func getBrain() -> NeuralNetProtocol { fatalError() }
//
//    func newBrain() {  }
//    func newLayer() { print("L") }
//    func newNeuron() { print("\tN\n\t\t", terminator: "") }
//
//    func reset() {}
//
//    func show(tabs: String, override: Bool = false) { }
//}

import CoreGraphics // For the math functions
class Translators: BrainOwnerProtocol {
    static let t = Translators()

    func setBias(_ value: ValueDoublet) { brain.setBias(value) }
    func setBias(_ baseline: Double, _ value: Double) { brain.setBias(baseline, value) }
    func setOutputFunction(_ function: @escaping NeuronOutputFunction) { brain.setOutputFunction(function) }
    func setThreshold(_ value: ValueDoublet) { brain.setThreshold(value) }
    func setThreshold(_ baseline: Double, _ value: Double) { brain.setThreshold(baseline, value) }

    private var brain: Brain!
    var layers = [Layer]()
    var reachedEndOfStrand: Bool = true

    func addActivator(_ active: Bool) { brain.addActivator(active) }

    func addWeight(_ value: ValueDoublet) { brain.addWeight(value) }
    func addWeight(_ baseline: Double, _ value: Double) { brain?.addWeight(baseline, value) }

    func closeBrain() { self.closeLayer() }
    func closeLayer() { brain.closeLayer() }
    func closeNeuron() { brain.closeNeuron() }

    func endOfStrand() {
        defer { reachedEndOfStrand = true }
        brain.endOfStrand()
    }

    func getBrain() -> Brain {
//        defer { self.brain = nil }
        return self.brain
    }

    func newBrain() { self.brain = Brain() }
    func newLayer() { self.brain.newLayer() }
    func newNeuron() { self.brain.newNeuron() }

    public func reset() { brain = nil }

    enum OutputFunctionName: String {
        case limiter, logistic, linear, tanh
    }

    static func tanh(_ theDouble: Double) -> Double { return CoreGraphics.tanh(theDouble) }
    static func logistic(_ theDouble: Double) -> Double { return 1.0 / (1.0 + exp(-theDouble)) }
    static func limiter(_ theDouble: Double) -> Double {
        let cappedAtPlusOne = min(1.0, theDouble)
        return max(-1, cappedAtPlusOne)
    }

    func setOutputFunction(_ functionName: String) {
        guard let fn = OutputFunctionName.init(rawValue: functionName)
            else { preconditionFailure("Function name not found") }

        guard !functionName.isEmpty
            else { preconditionFailure("No function name") }

        switch fn {
        case .limiter:  self.brain.setOutputFunction(Translators.limiter)
        case .linear: self.brain.setOutputFunction(Neuron.outputFunction)
        case .logistic: self.brain.setOutputFunction(Translators.logistic)
        case .tanh:   self.brain.setOutputFunction(Translators.tanh)
        }
    }

    func show(tabs: String, override: Bool = false) {
        if Utilities.thereBeNoShowing || !override { return }
        getBrain().show(tabs: "\t", override: override)
    }
}
