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

extension Translators {
class Neuron {
    var activators = [Bool]()
    var weights = [Double]()
    var bias: Double?, threshold: Double?
    
    let layerID: Int
    let neuronID: Int
    
    // Input port means the place where the stimulator
    // signals me. The position in the array indicates
    // which port to use, while the value in the array
    // indicates from which connection in the upper layer
    // to receive the input.
    var inputPortDescriptors = [Int]()
    
    // This is where the breeder stores the data from
    // the upper layer for stimulating this neuron.
    var inputPorts = [Double]()
    
    init(layerID: Int, neuronID: Int) {
        self.neuronID = neuronID
        self.layerID = layerID
    }
    
    func addWeight(_ weight: Double) { weights.append(weight) }
    func addActivator(_ active: Bool) { activators.append(active) }
    
    func endOfStrand() {}
    
    public func output() -> Double {
        let ws = weightedSum(), b = bias ?? 0, t = threshold ?? 0
        let biased = ws + b
        let abiased = abs(biased)
        
        let sign = (biased >= 0) ? 1.0 : -1.0
        
        // Make the same sign as ws + b, so we'll trigger on
        // the magnitude. Otherwise, we would send out the
        // threshold value with the wrong sign if ws + b
        // were negative but could trigger t by having a
        // large magnitude.
        let result = (abiased < abs(t)) ? biased : sign * t
        return result
    }
    
    func setTopLayerInputPort(whichUpperLayerNeuron: Int) {
//        print("Neuron setTopLayerInputPort(\(whichUpperLayerNeuron))")
        inputPortDescriptors.append(whichUpperLayerNeuron)
        activators.append(true)
        inputPorts.append(0)
        self.weights.append(1)
    }
    
    func setBias(_ value: Double) { bias = value }
    
    func setInputPorts(howManyInputsAreAvailable: Int) {
        if howManyInputsAreAvailable < 1 { fatalError("Shouldn't be in here if the previous layer has no outputs") }
        
        let adjustedInputCount = min(numberOfSenses, howManyInputsAreAvailable)
        
        var activationSS = 0, weightSS = 0, commLineNumber = 0
        
        while true {
//            print("Neuron(\(self.layerID):\(self.neuronID)) setInputPort()", terminator: "")
            if activationSS >= activators.count { break }
            if weightSS >= weights.count { break }
            if commLineNumber >= adjustedInputCount { commLineNumber = 0 }
            
            if activators[activationSS] {
                print("Neuron(\(self.layerID):\(self.neuronID) attaches port \(inputPortDescriptors.count) to commLine \(commLineNumber)")
                inputPortDescriptors.append(commLineNumber)
                inputPorts.append(0)    // Make room for another input
                weightSS += 1
//                print("\nNeuron(\(self.layerID):\(self.neuronID)) my port #\(inputPortDescriptors.count) goes to his comm line #\(commLineNumber); (\(inputPortDescriptors))")
            } //else { print("activator[\(activationSS)] is off") }
            
            activationSS += 1; commLineNumber += 1
            
        }
    }

    func setThreshold(_ value: Double) { threshold = value }
    
    func show(tabs: String, override: Bool = false) {
        if Utilities.thereBeNoShowing && !override { return }
        print(tabs + "\n\t\tN. ports = \(inputPortDescriptors.count): \(inputPortDescriptors) -- Neuron(\(self.layerID):\(self.neuronID))", terminator: "")
    }
    
    func stimulate(inputs: [Double]) -> Double? {
        if inputs.isEmpty { fatalError("stimulate() doesn't like empty inputs") }
        if inputPortDescriptors.isEmpty { return nil }
        
        // We might have a lot of input ports, but we're
        // dependent on how many inputs are available
        let adjustedInputCount = min(inputPortDescriptors.count, inputs.count)
        
        for portNumber in 0..<adjustedInputCount {
//            print("\nfStimulating Neuron (\(self.layerID):\(self.neuronID)) on port \(portNumber), data \(inputs[portNumber])")
            inputPorts[portNumber] = inputs[portNumber]
        }
        
//        print("Returning \(self.output())")
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
                
                let theWeightedSum = theDataFromHim * theWeightValue
                
                output += theWeightedSum
                
                let _ = "port(\(portNumberWhereIGetTheDataFromHim))"
                let _ = "from neuron(\(theNeuronGivingMeInputOnThisPort)) -> \(theDataFromHim)"
                let _ = "weight(\(ssIntoWeightsArrayCoincidentallyIs)) -> \(theWeightValue)"
                let _ = "yield(\(theDataFromHim) * \(theWeightValue)) -> running total(\(output))"
                
//                print(p + " " + f + " " + y + " " + w)
        }
        
//        print("T(\(output))")
        return output
    }
}
}
