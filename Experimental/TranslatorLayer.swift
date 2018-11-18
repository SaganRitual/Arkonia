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
class Layer {
    var neurons = [Neuron]()
    var howManyNeuronsInSensesLayer = 0
    var howManyNeuronsInOutputsLayer = 0
    var underConstruction: Neuron?
    
    func addActivator(_ active: Bool) { if let u = underConstruction { u.addActivator(active) } }
    func addWeight(_ weight: Double) { if let u = underConstruction { u.addWeight(weight) } }
    
    func closeNeuron() { if let u = underConstruction { neurons.append(u) }; underConstruction = nil }
    
    func setTopLayerInputPorts() {
        for (ss, neuron) in zip(0..., neurons) {
            neuron.setTopLayerInputPort(whichUpperLayerNeuron: ss)
        }
    }
    
    func connectNeurons(howManyInputsAreAvailable: Int) {
        for neuron in neurons {
            neuron.setInputPorts(howManyInputsAreAvailable: howManyInputsAreAvailable)
        }
    }
    
    func endOfStrand() { for neuron in neurons { neuron.endOfStrand() } }
    
    func newNeuron() { underConstruction = Neuron() }
    
    func setBias(_ value: Double) { underConstruction?.setBias(value) }
    func setThreshold(_ value: Double) { underConstruction?.setThreshold(value) }
    
    func show(tabs: String, override: Bool = false) {
        if Utilities.thereBeNoShowing && !override { return }
        print("\n\tL.\n\(tabs)")
        for neuron in neurons {
            neuron.show(tabs: tabs + "", override: override)
        }
    }
    
    func stimulate(inputs: [Double]) -> [Double] {
        var outputs = [Double]()
        print("Layer stimulate")
        for n in self.neurons {
            guard let r = n.stimulate(inputs: inputs)  else { continue }
            outputs.append(r)
        }
        print("Layer stimulate finished: ", outputs)
        return outputs
    }
}

}
