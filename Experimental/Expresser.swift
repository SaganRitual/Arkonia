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
    var layers: [Expresser.Layer] { get set }

    func generateRandomSensoryInput() -> [Double]
    func show()
    func stimulate(sensoryInput: [Double]) -> [Double]
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
    var layers = [Expresser.Layer]()
    var reachedEndOfStrand = false
    var underConstruction: Expresser.Layer!
    
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
    
    func reset() {
        reachedEndOfStrand = false
        layers.removeAll()
    }
    
    func setBias(_ value: Double) { underConstruction!.setBias(value) }
    func setThreshold(_ value: Double) { underConstruction!.setThreshold(value) }
}

extension Expresser {
    class Brain: BrainProtocol {
        var layers: [Expresser.Layer]
        
        init(layers: [Layer]) { self.layers = layers }
        
        func show() {
            print("Brain:")
            for (ss, layer) in zip(0..., layers) { layer.show(ss) }
        }
        
        func stimulate(sensoryInput: [Double]) -> [Double] {
            var previousLayerOutputs = sensoryInput
            
            for layer in self.layers {
                if previousLayerOutputs.isEmpty { return [] }
                previousLayerOutputs =
                    layer.stimulate(inputs: previousLayerOutputs)
            }
            
            return previousLayerOutputs
        }
        
        func generateRandomSensoryInput() -> [Double] {
            var s = [Double]()
            for _ in 0..<layers[0].neurons.count {
                let random = Double.random(in: -100...100).dTruncate()
                s.append(random)
            }
            return s
        }
    }
 
    class Layer {
        var neurons = [Neuron]()
        var underConstruction: Neuron!
        var firstLayer = true
        
        func addActivator(_ value: Bool) { underConstruction.activators.append(value) }
        func addWeight(_ value: Double) { underConstruction.weights.append(value) }

        func newNeuron() { underConstruction = Neuron() }
        
        func endOfStrand() { closeNeuron() }
        
        func setBias(_ value: Double) { underConstruction.bias = value }
        func setThreshold(_ value: Double) { underConstruction.threshold = value }
        
        func show(_ layerSS: Int) {
            print("Layer \(layerSS):")
            for (ss, neuron) in zip(0..., neurons) { neuron.show(ss) }
        }
        
        func stimulate(inputs: [Double]) -> [Double] {
            var outputs = [Double]()
            
            for n in self.neurons {
                outputs.append(n.stimulate(inputs: inputs))
            }
            
            return outputs
        }

    }
    
    class Neuron {
        var bias: Double?, threshold: Double?
        var activators = [Bool](), weights = [Double]()
        
        var inputLineSwitches = [Int]()
        var inputLines = [Double]()
        
        func addActivator(_ active: Bool) { activators.append(active) }
        func addWeight(_ weight: Double) { weights.append(weight) }
        
        func stimulate(inputs: [Double]) -> Double {
            if inputs.isEmpty { fatalError("Shouldn't be in here if the previous layer has no outputs") }
            
            for (theSwitch, inputLineSS) in zip(inputLineSwitches, 0...) {
                inputLines[inputLineSS] = inputs[theSwitch]
            }
            
            return self.output()
        }

        func postInit(inputLineDescriptor: Range<Int>) {
            if activators.isEmpty || weights.isEmpty { return }
            if !activators.reduce(false, { $0 && $1 }) { return }
            
            if inputLineDescriptor.isEmpty {
                let theOnlyInputLine = inputLineDescriptor.endIndex
                inputLineSwitches[0] = theOnlyInputLine
                return
            }

            var weightSS = 0
            
            for inputLineSS in inputLineDescriptor {
                if weightSS >= inputLineSS { return }
                
                if self.activators[inputLineSS] {
                    inputLineSwitches.append(inputLineSS)
                }

                if self.activators[inputLineSS] { weightSS += 1 }

                inputLineSwitches.append(inputLineSS)
            }
        }

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

extension Expresser.Neuron {
    public func output() -> Double {
        let ws = weightedSum(), b = bias ?? 0, t = threshold ?? 0
        return (abs(ws + t) > abs(t)) ? (ws + b) : t
    }

    private func weightedSum() -> Double {
        var output: Double = 0
        
        for (weightSS, line) in zip(0..., self.inputLines) {
            output += line * weights[weightSS]
        }
        
        return output
    }
}

extension Expresser.Layer {
    func closeNeuron() {
        if let u = underConstruction {
            neurons.append(u)
            
            // 0..<neurons.count
            var start = 0, end = neurons.count
            
            // If there's a previous layer, we tell all the
            // neurons in this layer about all the neurons
            // in the previous layer. If there's no previous
            // layer, ie, we're working on the top layer, we
            // force each neuron to take only one input, to
            // make life really easy for the selector function.
            
            for (n, ss) in zip(neurons, 0...) {
                // ss..<ss  Shows as empty, but endIndex == n in a range of n..<n
                if firstLayer { start = ss; end = ss }
                n.postInit(inputLineDescriptor: start..<end)
            }
        }
        
        firstLayer = false
        underConstruction = nil
    }

    func getOutputs(inputs: [Double]) -> [Double] {
        var outputs = [Double]()
        
        
        for n in neurons {
            for (theSwitch, ss) in zip(n.inputLineSwitches, 0...) {
                n.weights[ss] = inputs[theSwitch]
            }
            
            outputs.append(n.output())
        }
        
        return outputs
    }
}
