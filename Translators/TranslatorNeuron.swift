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

struct ValueDoublet: CustomStringConvertible {
    var baseline = 0.0
    var value = 0.0

    var description: String {
        return "(b[\(baseline.dTruncate())]v[\(value.dTruncate())])"
    }

    init() { baseline = 0.0; value = 0.0 }
    init(_ iffy: ValueDoublet?) { baseline = iffy?.baseline ?? 0.0; value = iffy?.value ?? 0.0 }
    init(_ halflet: Double) { self.baseline = 0; self.value = halflet }
    init(_ doublet: ValueDoublet) { self.baseline = doublet.baseline; self.value = doublet.value }
    init(_ baseline: Double, _ value: Double) { self.baseline = baseline; self.value = value }
    init(_ baseline: Int, _ value: Int) { self.baseline = Double(baseline); self.value = Double(value) }

    static func == (_ lhs: ValueDoublet, _ rhs: Double) -> Bool { return lhs.value == rhs }
    static func != (_ lhs: ValueDoublet, _ rhs: Double) -> Bool { return !(lhs == rhs) }
    static func + (_ lhs: ValueDoublet, _ rhs: Double) -> Double { return lhs.value + rhs }
    static func + (_ lhs: Double, _ rhs: ValueDoublet) -> Double { return rhs + lhs }
}

typealias NeuronOutputFunction = (Double) -> Double

extension Translators {

class Neuron: CustomStringConvertible {
    var activators = [Bool]()
    var bias = 0.0
    var weights = [ValueDoublet]()
    var commLinesUsed = [Int]() // Strictly for VBrain's display purposes

    var layerSSInBrain = 0
    var myTotalOutput: Double?
    var neuronSSInLayer = 0
    var hasClients = false
    var isMotorNeuron = false

    var hasOutput: Bool { return myTotalOutput != nil }

    static let outputFunction: NeuronOutputFunction =
            { (_ input: Double) -> Double in return input }

    var outputFunction = Neuron.outputFunction

    var description: String { return "Neuron(\(self.layerSSInBrain):\(neuronSSInLayer))" }

    init(layerSSInBrain: Int, neuronSSInLayer: Int) {
        self.layerSSInBrain = layerSSInBrain
        self.neuronSSInLayer = neuronSSInLayer
    }

    func accumulateBias(_ value: Double) { bias += value }
    func addWeight(_ value: ValueDoublet) { weights.append(value) }
    func addWeight(_ baseline: Double, _ value: Double) { weights.append(ValueDoublet(baseline, value)) }
    func addActivator(_ active: Bool) { activators.append(active) }

    func endOfStrand() {}

    public func output(_ inputs: [(Double, Double)?]) -> Double? {
        let cm: [Double] = inputs.compactMap
            { if let d = $0 { return d.0 * d.1 } else { return nil } }

        if cm.isEmpty { /*print("c", terminator: "");*/ return nil }

        let weightedSum = cm.reduce(0.0) { $0 + $1 }

        let bias = ValueDoublet(self.bias)

        myTotalOutput = outputFunction(weightedSum + bias)
        return myTotalOutput
    }

    func setOutputFunction(_ function: @escaping NeuronOutputFunction) { self.outputFunction = function }

    func show(tabs: String, override: Bool = false) {
        if Utilities.thereBeNoShowing && !override { return }
        print(tabs + "\n\t\tN. \(self) ", terminator: "")
        var separator = ""
        weights.forEach {
            print("\(separator)\($0)", terminator: "")
            separator = ", "
        }
    }

    public func stimulate(inputSources: [Double?]) -> Double? {
        var outputSansBias: Double?
        var commLine_ = 0

        var commLine: Int {
            get { return commLine_ % inputSources.count }
            set { commLine_ = newValue }
        }

        var rCommLine = inputSources.count

                func nextCommLine(_ preAdvance: Bool) {
                    if preAdvance { commLine += 1 }
                    while inputSources[commLine] == nil
                        { commLine += 1 }
                }

                func rNextCommLine(_ preAdvance: Bool) {
                    if preAdvance { rCommLine -= 1; if rCommLine == -1 { rCommLine = inputSources.count - 1 } }
                    while inputSources[rCommLine] == nil
                        { rCommLine -= 1; if rCommLine == -1 { rCommLine = inputSources.count - 1 } }
                }

        nextCommLine(false)  // Primer
        rNextCommLine(true)  // Primer
        var tWeights = Array(weights)
        for activator in activators {
            if tWeights.isEmpty { break }

            let whichLine = activator ? commLine : rCommLine

            guard let inputValue = inputSources[whichLine]
                else { preconditionFailure("We're not supposed to get nil from nextCommLine()") }

            outputSansBias = (outputSansBias ?? 0.0) + tWeights.pop().value * inputValue

            commLinesUsed.append(whichLine)  // Remember for the VBrain display

            nextCommLine(true)
            rNextCommLine(false)
        }

//        print("N(\(layerSSInBrain):\(neuronSSInLayer)) input \(commLinesUsed) output \(outputSansBias ?? -42.42)")

        return outputSansBias
    }
}
}
