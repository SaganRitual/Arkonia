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

extension TestTranslators {
class Neuron {
    var activators = [Bool]()
    var weights = [Double]()
    var bias: Double?, threshold: Double?
    
    // Input port means the place where the stimulator
    // signals me. The position in the array indicates
    // which port to use, while the value in the array
    // indicates from which connection in the upper layer
    // to receive the input.
    var inputPortDescriptors = [Int]()
    
    // This is where the breeder stores the data from
    // the upper layer for stimulating this neuron.
    var inputPorts = [Double]()

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
        print("N output = \(result.sTruncate()), ws = \(ws), bias = \(bias?.sTruncate() ?? "<nil>"), threshold = \(threshold?.sTruncate() ?? "<nil>")")
        return result
    }
    
    func setTopLayerInputPort(whichUpperLayerNeuron: Int) {
        inputPortDescriptors.append(whichUpperLayerNeuron)
        activators.append(true)
        inputPorts.append(0)
        self.weights.append(1)
        
    }
    
    func setBias(_ value: Double) { bias = value }
    
    func setInputPorts(howManyInputsAreAvailable: Int) {
        if howManyInputsAreAvailable < 1 { fatalError("Shouldn't be in here if the previous layer has no outputs") }
        
        let adjustedInputCount = min(numberOfSenses, howManyInputsAreAvailable)
        
        // myPortNumber is the subscript into my ports descriptor.
        // hisNeuronNumber is his position in the row of neurons
        // above us.
        var activationSS = 0, weightSS = 0, availableLineSS = 0
        
        print(activators.count, weights.count, numberOfSenses, howManyInputsAreAvailable)
        while true {
            if activationSS >= activators.count { break }
            if weightSS >= weights.count { break }
            if availableLineSS >= adjustedInputCount { availableLineSS = 0 }
            
            if activators[activationSS] {
                inputPortDescriptors.append(availableLineSS)
                inputPorts.append(0)    // Make room for another input
                weightSS += 1
                print("t", terminator: "")
            } else { print("f", terminator: "") }
            print("\nt(\(availableLineSS), \(inputPortDescriptors), \(inputPorts))")
            availableLineSS += 1; activationSS += 1
        }
        print()
    }
    
    func setThreshold(_ value: Double) { threshold = value }
    
    func show(tabs: String, override: Bool = false) {
        if Utilities.thereBeNoShowing && !override { return }
        print(tabs + "\t\tN. ports = \(inputPortDescriptors.count): \(inputPortDescriptors)")
    }
    
    func stimulate(inputs: [Double]) -> Double? {
        if inputs.isEmpty { fatalError("Shouldn't be in here if the previous layer has no outputs") }
        if inputPortDescriptors.isEmpty { return nil }
        
        for portNumber in 0..<inputPortDescriptors.count {
            let inputLine = inputPortDescriptors[portNumber]
            inputPorts[portNumber] = inputs[inputLine]
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
                
                let theWeightedSum = theDataFromHim * theWeightValue
                
                output += theWeightedSum
                
                let p = "port(\(portNumberWhereIGetTheDataFromHim))"
                let f = "from neuron(\(theNeuronGivingMeInputOnThisPort)) -> \(theDataFromHim)"
                let y = "weight(\(ssIntoWeightsArrayCoincidentallyIs)) -> \(theWeightValue)"
                let w = "yield(\(theDataFromHim) * \(theWeightValue)) -> running total(\(output))"
                
                print(p + " " + f + " " + y + " " + w)
        }
        
        print("T(\(output))")
        return output
    }
}
}
