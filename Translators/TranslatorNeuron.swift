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

typealias NeuronOutputFunction = (Double) -> Double

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
    var foundViableInput = false
    
    // This is where the breeder stores the data from
    // the upper layer for stimulating this neuron.
    var inputPorts = [Double]()
    
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
    
    public func output(_ inputs: [WeightSignal]) -> Double {
        var weightedSum = 0.0
        for input in inputs {
            guard let w = input.weight else { continue }
            weightedSum += input.input * w.value
        }
        
        let bias = { () -> Double in if let b = self.bias { return b.value }; return 0.0 }()
        
        let result = outputFunction(weightedSum + bias)
        return result
    }
    
    func setBias(_ bias: ValueDoublet) { self.bias = bias }
    func setBias(_ baseline: Double, _ value: Double) { bias = ValueDoublet(baseline, value) }

    func setOutputFunction(_ function: @escaping NeuronOutputFunction) { self.outputFunction = function }

    func setThreshold(_ threshold: ValueDoublet) { self.threshold = threshold }
    func setThreshold(_ baseline: Double, _ value: Double) { threshold = ValueDoublet(baseline, value) }
        
    func setTopLayerInputPort(whichUpperLayerNeuron: Int) {
        inputPortDescriptors.append(whichUpperLayerNeuron)
        activators.append(true)
        inputPorts.append(0)
        self.weights.append(ValueDoublet(1, 1))
    }

    func show(tabs: String, override: Bool = false) {
        if Utilities.thereBeNoShowing && !override { return }
        print(tabs + "\n\t\tN. ports = \(inputPortDescriptors.count): \(inputPortDescriptors) -- \(self)", terminator: "")
    }
    
    struct WeightSignal {
        var weight: ValueDoublet?
        var input = 0.0
        init() {}
        init(_ weight: ValueDoublet) { self.weight = weight }
    }
    
    func stimulate(inputs: [Double]) -> Double? {
        if inputs.isEmpty { fatalError("stimulate() doesn't like empty inputs") }
        if weights.isEmpty { return nil }

        var myInputPorts = [WeightSignal]()
        var tWeights = Array(weights)
        if tWeights.isEmpty {
            print("wtf")
        }
        for (a, _) in zip(activators, weights) {
            
            let ws: WeightSignal = { () -> WeightSignal in
                if a { let p = tWeights.pop(); return WeightSignal(p) }
                else { return WeightSignal() }
            }()
            
            myInputPorts.append(ws)
        }
        
        var ssMyInputPorts = 0, ssInputs = 0

        while ssMyInputPorts < myInputPorts.count {
            
            if myInputPorts[ssMyInputPorts].weight != nil {
                myInputPorts[ssMyInputPorts].input = inputs[ssInputs]
            }

            ssMyInputPorts += 1; ssInputs = (ssInputs + 1) % inputs.count
        }
        
        return self.output(myInputPorts)
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
