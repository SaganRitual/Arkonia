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

struct AKNet {}

//// Genome display during decode
class Translators: BrainOwnerProtocol {
    func accumulateBias(_ value: Double) {
        print("Bias \(value.sciTruncate(5))")
    }

    func setOutputFunction(_ functionName: String) {
        print("Fn \(functionName)")
    }

    static let t = Translators()

    static var numberOfSenses = 5
    static var numberOfMotorNeurons = 5// "Zoe Bishop".count

    var reachedEndOfStrand: Bool = true

    func addActivator(_ active: Bool) { print("\n\t\t\tA(\(String(active))).", terminator: "") }

    func addWeight(_ value: ValueDoublet) {  print("W(\(value)).", terminator: "") }
    func addWeight(_ baseline: Double, _ value: Double)
        { addWeight(ValueDoublet(baseline, value)) }

    func closeBrain() {  }
    func closeLayer() { print() }
    func closeNeuron() { print() }

    func connectLayers() { }

    func endOfStrand() { reachedEndOfStrand = true; print() }

    func getBrain() -> AKNet { preconditionFailure() }
    func getBrain() -> Translators.Brain { preconditionFailure() }
    func getBrain() -> NeuralNetProtocol { preconditionFailure() }

    func newBrain() {  }
    func newLayer() { print("L") }
    func newNeuron() { print("\tN\n\t\t", terminator: "") }

    func reset() {}

    func show(tabs: String, override: Bool = false) { }
}

//import CoreGraphics // For the math functions
//class Translators: BrainOwnerProtocol {
//    static let t = Translators()
//
//    func setOutputFunction(_ functionName: String) {
//        AFn.setOutputFunction(functionName, for: brain)
//    }
//
//    private var brain: Brain!
//    var layers = [Layer]()
//    var reachedEndOfStrand: Bool = true
//
//    func accumulateBias(_ value: Double) { brain.accumulateBias(value) }
//
//    func addActivator(_ active: Bool) { brain.addActivator(active) }
//
//    func addWeight(_ value: ValueDoublet) { brain.addWeight(value) }
//    func addWeight(_ baseline: Double, _ value: Double) { brain?.addWeight(baseline, value) }
//
//    func closeBrain() { self.closeLayer() }
//    func closeLayer() { brain.closeLayer() }
//    func closeNeuron() { brain.closeNeuron() }
//
//    func endOfStrand() {
//        defer { reachedEndOfStrand = true }
//        brain.endOfStrand()
//    }
//
//    func getBrain() -> AKNet { return self.brain.net! }
//    func getBrain() -> Translators.Brain { return self.brain }
//
//    func newBrain() { self.brain = Brain() }
//    func newLayer() { self.brain.newLayer() }
//    func newNeuron() { self.brain.newNeuron() }
//
//    public func reset() { brain = nil }
//
//    func show(tabs: String, override: Bool = false) {
////        if Utilities.thereBeNoShowing || !override { return }
////        getBrain().show(tabs: "\t", override: override)
//    }
//}
