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

protocol BrainProtocol {
    func show()
}

protocol ExpresserProtocol {
    var reachedEndOfStrand: Bool { get set }
    
    func addActivator(_ active: Bool)
    func addWeight(_ weight: Double)
    
    func closeLayer()
    func closeNeuron()

    func endOfStrand()
    
    func getBrain() -> BrainProtocol
    
    func newBrain()
    func newLayer()
    func newNeuron()
    
    func reset()
    
    func setBias(_ value: Double)
    func setThreshold(_ value: Double)
}

class Expresser: ExpresserProtocol {
    var layers = [Layer]()
    var reachedEndOfStrand = false
    var underConstruction: Layer!
    
    func addActivator(_ active: Bool) { underConstruction.underConstruction.addActivator(active) }
    func addWeight(_ weight: Double) { underConstruction.underConstruction.addWeight(weight) }
    
    func closeLayer() {
        if let u = underConstruction { layers.append(u) }
        underConstruction = nil
    }

    func closeNeuron() { underConstruction.closeNeuron() }
    
    func endOfStrand() {
        if let u = underConstruction {
            layers.append(u)
            underConstruction = nil
            reachedEndOfStrand = true
        }
        
        if let layer = layers.last { layer.endOfStrand() }
    }
    
    func getBrain() -> BrainProtocol { return Brain(layers: layers) }
    
    func newLayer() {
        if let u = underConstruction { layers.append(u); underConstruction = nil }
        else { underConstruction = Layer() }
    }
    
    func newBrain() { layers = []; underConstruction = nil }
    func newNeuron() { underConstruction.newNeuron() }
    
    func reset() { reachedEndOfStrand = false; layers.removeAll() }
    
    func setBias(_ value: Double) { underConstruction!.setBias(value) }
    func setThreshold(_ value: Double) { underConstruction!.setThreshold(value) }
}

extension Expresser {
    class Brain: BrainProtocol {
        let layers: [Layer]

        init(layers: [Layer]) { self.layers = layers }
        
        func show() {
            print("Brain:")
            for (ss, layer) in zip(0..., layers) { layer.show(ss) }
        }
    }
 
    class Layer {
        var neurons = [Neuron]()
        var underConstruction: Neuron!
        
        func addActivator(_ value: Bool) { underConstruction.activators.append(value) }
        func addWeight(_ value: Double) { underConstruction.weights.append(value) }

        func closeNeuron() {
            if let u = underConstruction { neurons.append(u) }
            underConstruction = nil
        }

        func newNeuron() { underConstruction = Neuron() }
        
        func endOfStrand() { closeNeuron() }
        
        func setBias(_ value: Double) { underConstruction.bias = value }
        func setThreshold(_ value: Double) { underConstruction.threshold = value }
        
        func show(_ layerSS: Int) {
            print("Layer \(layerSS):")
            for (ss, neuron) in zip(0..., neurons) { neuron.show(ss) }
        }
        
    }
    
    class Neuron {
        var bias: Double?
        var threshold: Double?
        
        var activators = [Bool](), weights = [Double]()
        
        func addActivator(_ active: Bool) { activators.append(active) }
        func addWeight(_ weight: Double) { weights.append(weight) }
        func setBias(_ value: Double) { bias = value }
        func setThreshold(_ value: Double) { threshold = value }
        
        func show(_ neuronSS: Int) {
            print("Neuron \(neuronSS):")
            
            print("\tActivators: ", terminator: "")
            for a in activators { print("A(\(a)) ", terminator: "") }
            print("")

            print("\tWeights: ", terminator: "")
            for w in weights { print("W(\(w)) ", terminator: "") }
            print("")
            
            let biasString = (bias == nil) ? "<nil>" : String(bias!)
            let thresholdString = (threshold == nil) ? "<nil>" : String(threshold!)
            print("\tBias: \(biasString), Threshold \(thresholdString)")
        }
    }
}
