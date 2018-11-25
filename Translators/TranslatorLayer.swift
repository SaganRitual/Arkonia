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
class Layer: CustomStringConvertible {
    var neurons = [Neuron]()
    var howManyNeuronsInSensesLayer = 0
    var howManyNeuronsInOutputsLayer = 0
    var underConstruction: Neuron?
    
    var layerSSInBrain = 0

    var description: String { return "Layer(\(self.layerSSInBrain))" }

    init(layerSSInBrain: Int) { self.layerSSInBrain = layerSSInBrain }

    func addActivator(_ active: Bool) { underConstruction?.addActivator(active) }
    
    func addWeight(_ value: ValueDoublet) { underConstruction?.addWeight(value) }
    func addWeight(_ baseline: Double, _ value: Double) { underConstruction?.addWeight(baseline, value) }
    
    func closeNeuron() { if let u = underConstruction { neurons.append(u) }; underConstruction = nil }
    
    func connectNeurons(ctAvailableInputs: Int, previousLayer: Layer?, isMotorNeuronLayer: Bool = false) throws {
        let nextCommLineForMotorNeurons: Int? = isMotorNeuronLayer ? 0 : nil
 
        var isViableLayer = false
        var ncl = nextCommLineForMotorNeurons
        let ctAI = ctAvailableInputs

        for neuron in neurons {
            ncl = neuron.setInputPorts(ctAvailableInputs: ctAI, previousLayer: previousLayer, commLineOverride: ncl)
            
            if !neuron.inputPortDescriptors.isEmpty { isViableLayer = true }
        }
        
        if !isViableLayer { throw SelectionError.nonViableBrain }
    }
    
    func endOfStrand() { for neuron in neurons { neuron.endOfStrand() } }
    
    private func makeNeuron() -> Neuron {
        return Neuron(layerSSInBrain: self.layerSSInBrain, neuronSSInLayer: neurons.count)
    }
    
    func newNeuron() { underConstruction = makeNeuron() }

    func setBias(_ value: ValueDoublet) { underConstruction?.setBias(value) }
    func setBias(_ baseline: Double, _ value: Double) { underConstruction?.setBias(baseline, value) }
    
    func setOutputFunction(_ function: @escaping NeuronOutputFunction) { underConstruction?.setOutputFunction(function) }

    func setThreshold(_ value: ValueDoublet) { underConstruction?.setThreshold(value) }
    func setThreshold(_ baseline: Double, _ value: Double) { underConstruction?.setThreshold(baseline, value) }
    
    func setTopLayerInputPorts() {
        for (ss, neuron) in zip(0..., neurons) {
            neuron.foundViableInput = true  // The top layer always works
            neuron.setTopLayerInputPort(whichUpperLayerNeuron: ss)
        }
    }

    func show(tabs: String, override: Bool = false) {
        if Utilities.thereBeNoShowing && !override { return }
        print("\n\tL.\n\(tabs)")
        for neuron in neurons {
            neuron.show(tabs: tabs + "", override: override)
        }
    }
    
    func stimulate(inputs: [Double]) -> [Double] {
        var outputs = [Double]()
//        print("Layer (\(self.myID)) ")
        for n in self.neurons {
            guard let r = n.stimulate(inputs: inputs)  else { continue }
            outputs.append(r)
        }
        return outputs
    }
}

}
