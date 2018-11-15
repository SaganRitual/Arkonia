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

protocol ExpresserProtocol {
    var reachedEndOfStrand: Bool { get set }
    
    func addActivator(_ active: Bool)
    func addWeight(_ weight: Double)
    
    func closeLayer()
    func closeNeuron()

    func endOfStrand()
    
    func newLayer()
    func newNeuron()
    
    func reset()
    
    func setBias(_ value: Double)
    func setThreshold(_ value: Double)
}

class Expresser {
    func newBrain() -> Brain {
        return Brain()
    }

    class Brain: ExpresserProtocol {
        var reachedEndOfStrand = false
        
        var layerStack = [Layer]()
        var underConstruction: Layer!
        
        func addActivator(_ active: Bool) { underConstruction.underConstruction.addActivator(active) }
        func addWeight(_ weight: Double) { underConstruction.underConstruction.addWeight(weight) }
        
        func closeLayer() { if let u = underConstruction { layerStack.append(u) }}
        func closeNeuron() { underConstruction.closeNeuron() }
        
        func endOfStrand() {
            if let u = underConstruction {
                layerStack.append(u)
                underConstruction = nil
                reachedEndOfStrand = true
            }
            
            if let layer = layerStack.last { layer.endOfStrand() }
        }
        
        func newLayer() {
            if let u = underConstruction { layerStack.append(u); underConstruction = nil }
            else { underConstruction = Layer() }
        }
        
        func newNeuron() { underConstruction.newNeuron() }
        
        func reset() { reachedEndOfStrand = false; layerStack.removeAll() }
        
        func setBias(_ value: Double) { underConstruction!.setThreshold(value) }
        func setThreshold(_ value: Double) { underConstruction!.setThreshold(value) }
    }
}

extension Expresser {
    class Layer {
        var neurons = [Neuron]()
        var underConstruction: Neuron!
        
        func addActivator(_ value: Bool) { underConstruction.activators.append(value) }
        func addWeight(_ value: Double) { underConstruction.weights.append(value) }

        func closeNeuron() { neurons.append(underConstruction); underConstruction = nil }
        func newNeuron() { underConstruction = Neuron() }
        
        func endOfStrand() { closeNeuron() }
        
        func setBias(_ value: Double) { underConstruction.bias = value }
        func setThreshold(_ value: Double) { underConstruction.threshold = value }
    }
    
    class Neuron {
        var bias: Double?
        var threshold: Double?
        
        var activators = [Bool](), weights = [Double]()
        
        func addActivator(_ active: Bool) { activators.append(active) }
        func addWeight(_ weight: Double) { weights.append(weight) }
        func setBias(_ value: Double) { bias = value }
        func setThreshold(_ value: Double) { threshold = value }
    }
}
