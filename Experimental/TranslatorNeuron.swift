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
    var baseline: Double, value: Double
    
    init() { baseline = 0.0; value = 0.0 }
    init(_ doublet: ValueDoublet) { self.baseline = doublet.baseline; self.value = doublet.value }
    init(_ baseline: Double, _ value: Double) { self.baseline = baseline; self.value = value }
    init(_ baseline: Int, _ value: Int) { self.baseline = Double(baseline); self.value = Double(value) }

    static func ==(_ lhs: ValueDoublet, _ rhs: Double) -> Bool { return lhs.value == rhs }
    static func !=(_ lhs: ValueDoublet, _ rhs: Double) -> Bool { return !(lhs == rhs) }
}

extension Translators {
    class Neuron: CustomStringConvertible {
    var activators = [Bool]()
    var weights = [ValueDoublet]()
    var bias: ValueDoublet?, threshold: ValueDoublet?
    
    var layerSSInBrain = 0
    var neuronSSInLayer = 0
    
    // Input port means the place where the stimulator
    // signals me. The position in the array indicates
    // which port to use, while the value in the array
    // indicates from which connection in the upper layer
    // to receive the input.
    var inputPortDescriptors = [Int]()
    
    // This is where the breeder stores the data from
    // the upper layer for stimulating this neuron.
    var inputPorts = [Double]()
    
    var description: String { return "Neuron(\(self.layerSSInBrain):\(neuronSSInLayer))" }
    
    init(layerSSInBrain: Int, neuronSSInLayer: Int) {
        self.layerSSInBrain = layerSSInBrain
        self.neuronSSInLayer = neuronSSInLayer
    }
    
    func addWeight(_ value: ValueDoublet) { weights.append(value) }
    func addWeight(_ baseline: Double, _ value: Double) { weights.append(ValueDoublet(baseline, value)) }
    func addActivator(_ active: Bool) { activators.append(active) }
    
    func endOfStrand() {}
    
    public func output() -> Double {
        let ws = weightedSum(), b = bias ?? ValueDoublet(0.0, 0.0), t = threshold ?? ValueDoublet(0.0, 0.0)
        let biased = ws + b.value
        let abiased = abs(biased)
        
        let sign = (biased >= 0) ? 1.0 : -1.0
        
        // Make the same sign as ws + b, so we'll trigger on
        // the magnitude. Otherwise, we would send out the
        // threshold value with the wrong sign if ws + b
        // were negative but could trigger t by having a
        // large magnitude.
        let result = (abiased < abs(t.value)) ? biased : sign * t.value
        return result
    }
    
    func setTopLayerInputPort(whichUpperLayerNeuron: Int) {
        inputPortDescriptors.append(whichUpperLayerNeuron)
        activators.append(true)
        inputPorts.append(0)
        self.weights.append(ValueDoublet(1, 1))
    }
    
    func setBias(_ value: ValueDoublet) { bias?.baseline = value.baseline; bias?.value = value.value }
    func setBias(_ baseline: Double, _ value: Double) { bias?.baseline = baseline; bias?.value = value }
    
    func setInputPorts(howManyInputsAreAvailable: Int) {
        if howManyInputsAreAvailable < 1 { fatalError("Shouldn't be in here if the previous layer has no outputs") }
        
        let adjustedInputCount = howManyInputsAreAvailable// min(numberOfSenses, howManyInputsAreAvailable)
        
        var activationSS = 0, weightSS = 0, commLineNumber = 0
        
        while true {
            if activationSS >= activators.count { break }
            if weightSS >= weights.count { break }
            if commLineNumber >= adjustedInputCount { commLineNumber = 0 }
            
            if activators[activationSS] {
                if !Utilities.thereBeNoShowing {
                    print("\(self) attaches port \(inputPortDescriptors.count) to commLine \(commLineNumber) in older sib of \(self.layerSSInBrain)")
                }
                inputPortDescriptors.append(commLineNumber)
                inputPorts.append(0)    // Make room for another input
                weightSS += 1
            }
            
            activationSS += 1; commLineNumber += 1
            
        }
    }

    func setThreshold(_ value: ValueDoublet) { threshold?.baseline = value.baseline; threshold?.value = value.value }
    func setThreshold(_ baseline: Double, _ value: Double) { threshold?.baseline = baseline; threshold?.value = value }
    
    func show(tabs: String, override: Bool = false) {
        if Utilities.thereBeNoShowing && !override { return }
        print(tabs + "\n\t\tN. ports = \(inputPortDescriptors.count): \(inputPortDescriptors) -- \(self)", terminator: "")
    }
    
    func stimulate(inputs: [Double]) -> Double? {
        if inputs.isEmpty { fatalError("stimulate() doesn't like empty inputs") }
        if inputPortDescriptors.isEmpty { return nil }
        
        // We might have a lot of input ports, but we're
        // dependent on how many inputs are available
        let adjustedInputCount = min(inputPortDescriptors.count, inputs.count)
        
        for portNumber in 0..<adjustedInputCount {
            inputPorts[portNumber] = inputs[portNumber]
        }
        
        return self.output()
    }
    
    private func weightedSum() -> Double {
        var output: Double = 0
        
        var inputLinesDiag = [Int]()
        var diagString = String()
        for (ss, inputPortDescriptor) in zip(0..., self.inputPortDescriptors) {
            diagString += "neuron \(inputPortDescriptor) sending to me on my port \(ss)"
            inputLinesDiag.append(inputPortDescriptor)
        }
        
        for (portNumberWhereIGetTheDataFromHim, theNeuronGivingMeInputOnThisPort)
            in zip(0..., self.inputPortDescriptors) {
                
                let theDataFromHim = self.inputPorts[portNumberWhereIGetTheDataFromHim]
                let ssIntoWeightsArrayCoincidentallyIs = portNumberWhereIGetTheDataFromHim
                let theWeightValue = weights[ssIntoWeightsArrayCoincidentallyIs]
                
                let theWeightedSum = theDataFromHim * theWeightValue.value
                
                output += theWeightedSum
                
                let _ = "port(\(portNumberWhereIGetTheDataFromHim))"
                let _ = "from neuron(\(theNeuronGivingMeInputOnThisPort)) -> \(theDataFromHim)"
                let _ = "weight(\(ssIntoWeightsArrayCoincidentallyIs)) -> \(theWeightValue)"
                let _ = "yield(\(theDataFromHim) * \(theWeightValue)) -> running total(\(output))"
                
//                print(p + " " + f + " " + y + " " + w)
        }
        
        return output
    }
}
}
