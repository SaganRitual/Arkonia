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

// Genome display during decode
//class Translators: BrainOwnerProtocol {
//    static let t = Translators()
//
//    static let numberOfSenses = 5
//    static let numberOfMotorNeurons = "Zoe Bishop".count
//
//    func setBias(_ value: Double) { print("b(\(value.sTruncate())).", terminator: "") }
//    func setThreshold(_ value: Double) { print("t(\(value.sTruncate())).", terminator: "") }
//
//    var reachedEndOfStrand: Bool = true
//
//    func addActivator(_ active: Bool) { print("\n\t\t\tA(\(String(active))).", terminator: "") }
//    func addWeight(_ weight: Double) {  print("W(\(weight.sTruncate())).", terminator: "") }
//
//    func closeBrain() {  }
//    func closeLayer() { print() }
//    func closeNeuron() { print() }
//
//    func connectLayers() { }
//
//    func endOfStrand() { reachedEndOfStrand = true; print() }
//
//    func getBrain() -> LayerOwnerProtocol { fatalError() }
//
//    func newBrain() {  }
//    func newLayer() { print("L") }
//    func newNeuron() { print("\tN\n\t\t", terminator: "") }
//
//    func reset() {}
//
//    func show(tabs: String, override: Bool = false) { }
//}

class Translators: BrainOwnerProtocol {
    static let t = Translators()

    static let numberOfSenses = 5
    static let numberOfMotorNeurons = "Zoe Bishop".count

    func setBias(_ value: Double) { brain?.setBias(value) }
    func setThreshold(_ value: Double) { brain?.setThreshold(value) }

    var brain: Brain!
    var layers = [Layer]()
    var reachedEndOfStrand: Bool = true

    func addActivator(_ active: Bool) { brain?.addActivator(active) }
    func addWeight(_ weight: Double) { brain?.addWeight(weight) }

    func closeBrain() { self.closeLayer() }
    func closeLayer() { brain?.closeLayer() }
    func closeNeuron() { brain?.closeNeuron() }

    func connectLayers() { brain?.connectLayers() }

    func endOfStrand() {
        brain.endOfStrand()
        connectLayers()

        reachedEndOfStrand = true
    }

    func getBrain() -> LayerOwnerProtocol {
        return brain as LayerOwnerProtocol
    }

    func newBrain() { self.brain = Brain() }
    func newLayer() { self.brain.newLayer() }
    func newNeuron() { self.brain.newNeuron() }

    func reset() {}

    func show(tabs: String, override: Bool = false) {
        if Utilities.thereBeNoShowing || !override { return }
        getBrain().show(tabs: "\t", override: override)
    }
}
