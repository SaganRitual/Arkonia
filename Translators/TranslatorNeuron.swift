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

struct ValueDoublet {
    var baseline = 0.0
    var value = 0.0

    init() { baseline = 0.0; value = 0.0 }
    init(_ iffy: ValueDoublet?) { baseline = iffy?.baseline ?? 0.0; value = iffy?.value ?? 0.0 }
    init(_ halflet: Double) { self.baseline = 0; self.value = halflet }
    init(_ doublet: ValueDoublet) { self.baseline = doublet.baseline; self.value = doublet.value }
    init(_ baseline: Double, _ value: Double) { self.baseline = baseline; self.value = value }
    init(_ baseline: Int, _ value: Int) { self.baseline = Double(baseline); self.value = Double(value) }

    static func ==(_ lhs: ValueDoublet, _ rhs: Double) -> Bool { return lhs.value == rhs }
    static func !=(_ lhs: ValueDoublet, _ rhs: Double) -> Bool { return !(lhs == rhs) }
    static func  +(_ lhs: ValueDoublet, _ rhs: Double) -> Double { return lhs.value + rhs }
    static func  +(_ lhs: Double, _ rhs: ValueDoublet) -> Double { return rhs + lhs }
}

typealias NeuronOutputFunction = (Double) -> Double

extension Translators {

class Neuron: CustomStringConvertible {
    var activators = [Bool]()
    var weights = [ValueDoublet]()
    var bias: ValueDoublet?, threshold: ValueDoublet?
    
    var layerSSInBrain = 0
    var neuronSSInLayer = 0
    
    var foundViableInput = false
    
    // This is where the breeder stores the data from
    // the upper layer for stimulating this neuron.
    var inputPorts = [Double]()
    
    var inputPortDescriptors = [Int]()

    static let outputFunction: NeuronOutputFunction =
            { (_ input: Double) -> Double in return input }
    
    var outputFunction = Neuron.outputFunction

    var description: String { return "Neuron(\(self.layerSSInBrain):\(neuronSSInLayer))" }
    
    init(layerSSInBrain: Int, neuronSSInLayer: Int) {
        self.layerSSInBrain = layerSSInBrain
        self.neuronSSInLayer = neuronSSInLayer
    }
    
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

        let result = outputFunction(weightedSum + bias)
        return result
    }
    
    func setBias(_ bias: ValueDoublet) { self.bias = bias }
    func setBias(_ baseline: Double, _ value: Double) { bias = ValueDoublet(baseline, value) }

    func setOutputFunction(_ function: @escaping NeuronOutputFunction) { self.outputFunction = function }

    func setThreshold(_ threshold: ValueDoublet) { self.threshold = threshold }
    func setThreshold(_ baseline: Double, _ value: Double) { threshold = ValueDoublet(baseline, value) }

    func show(tabs: String, override: Bool = false) {
        if Utilities.thereBeNoShowing && !override { return }
        print(tabs + "\n\t\tN. \(inputPortDescriptors):(\(activators)) -- \(self)", terminator: "")
    }
    
    struct WeightSignal: CustomStringConvertible {
        var weight: ValueDoublet?
        var input_: Double?
        var input: Double {
            get { guard let i = input_ else { preconditionFailure() }; return i }
            set { input_ = newValue}
        }
        
        var description: String {
            var full = "WS: "
            guard let w = weight else { full += "<nil>"; return full }
            full +=  "W(b[\(w.baseline)]v[\(w.value)])_"
            return full
        }
        
        init() {}
        init(_ weight: Double) { self.weight = ValueDoublet(weight) }
        init(_ weight: ValueDoublet) { self.weight = weight }
    }
    
    func stimulate(_ inputs: [Double?]) -> Double? {
        if weights.isEmpty || activators.isEmpty || inputs.isEmpty { return nil }
        
        var ssWeight = 0
        var commLine = 0
        
        var signals = [(Double, Double)]()
        for activator in activators {
            defer { commLine = (commLine + 1) % inputs.count }
            
            if activator {
                if let input = inputs[commLine] {
                    
//                    print("N(\(layerSSInBrain):\(neuronSSInLayer)) weight \(ssWeight) goes to comm line \(commLine)")

                    // The input port descriptors have been demoted to
                    // just a helper for the UI. We don't use them for
                    // anything else, but instead we send our weight+input
                    // pairs directly to the ouput() function. This comment
                    // was correct on 3 Dec 2018
                    self.inputPortDescriptors.append(commLine)
                    signals.append((weights[ssWeight].baseline, input))
                    
                    foundViableInput = true

                    ssWeight += 1
                    if ssWeight >= weights.count { break }
                }
            }
        }
        
        return output(signals)
    }
}
}
