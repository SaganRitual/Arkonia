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

class TestTranslators: BrainOwnerProtocol {
    static let numberOfSenses = 1
    static let numberOfMotorNeurons = 1// "Zoe Bishop".count

    func setBias(_ value: Double) { brain?.setBias(value) }
    func setThreshold(_ value: Double) { brain?.setThreshold(value) }
    
    var brain: Brain!
    var layers = [Layer]()
    var reachedEndOfStrand: Bool = true
    
    func addActivator(_ active: Bool) { brain?.addActivator(active) }
    func addWeight(_ weight: Double) { brain?.addWeight(weight) }
    
    func closeBrain() { self.closeLayer() }
    func closeLayer() { brain?.closeLayer() }
    func closeNeuron() { brain?.closeNeuron() }
    
    func connectLayers() { brain?.connectLayers() }

    func endOfStrand() {
        newLayer()
        
        for _ in 0..<TestTranslators.numberOfMotorNeurons {
            newNeuron()
            addActivator(true)
            addWeight(1)
            setBias(0)
            setThreshold(Double.infinity)
            closeNeuron()
        }

        closeLayer()
        connectLayers()

        brain.endOfStrand()
        reachedEndOfStrand = true
    }
    
    func getBrain() -> LayerOwnerProtocol {
        return brain as LayerOwnerProtocol
    }
    
    func newBrain() { self.brain = Brain() }
    func newLayer() { self.brain.newLayer() }
    func newNeuron() { self.brain.newNeuron() }
    
    func show(tabs: String, override: Bool = false) {
        if Utilities.thereBeNoShowing || !override { return }
        getBrain().show(tabs: "\t", override: override)
    }
}

extension TestTranslators {
    class Brain: LayerOwnerProtocol {
        var layers = [Layer]()
        var underConstruction: Layer!
        
        var firstLayer = true
        
        func addActivator(_ active: Bool) { if let u = underConstruction { u.addActivator(active) } }
        func addWeight(_ weight: Double) { if let u = underConstruction { u.addWeight(weight) } }

        func closeLayer() {
            if let u = underConstruction { layers.append(u); underConstruction = nil }
        }

        func closeNeuron() { underConstruction?.closeNeuron() }
        
        func setInputs(_ inputs: [Int]) {
            
        }
        
        func connectLayers() {
            var previousLayer: Layer?
            for layer in layers {
                defer { previousLayer = layer }
                guard let p = previousLayer else { layer.setTopLayerInputPorts(); continue }
                layer.connectNeurons(howManyInputsAreAvailable: p.neurons.count)
            }
        }
        
        func endOfStrand() {
            
            for layer in layers { layer.endOfStrand() }
            
        }

        func newLayer() {
            if firstLayer {
                firstLayer = false

                underConstruction = Layer()

                for _ in 0..<TestTranslators.numberOfSenses {
                    newNeuron()
                    underConstruction?.addActivator(true)
                    underConstruction?.addWeight(1)
                    underConstruction?.setBias(0)
                    underConstruction?.setThreshold(Double.infinity)
                    closeNeuron()
                }
                
                closeLayer()
            }

            underConstruction = Layer()
        }

        func newNeuron() { underConstruction?.newNeuron() }
        func setBias(_ value: Double) { underConstruction?.setBias(value) }
        func setThreshold(_ value: Double) { underConstruction?.setThreshold(value) }

        func show(tabs: String, override: Bool = false) {
            if Utilities.thereBeNoShowing && !override { return }
            print("Brain: ")
            for layer in layers { layer.show(tabs: "", override: override) }
            print()
        }
        
        func stimulate(inputs: [Double]) -> [Double] {
            var previousLayerOutputs = inputs
            
            for layer in self.layers {
                if previousLayerOutputs.isEmpty { return [] }
                previousLayerOutputs =
                    layer.stimulate(inputs: previousLayerOutputs)
            }

            return previousLayerOutputs
        }
    }
    
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
            print("\(tabs)L.\n\(tabs)")
            for neuron in neurons {
                neuron.show(tabs: tabs + "", override: override)
            }
        }
        
        func stimulate(inputs: [Double]) -> [Double] {
            var outputs = [Double]()
            
            for n in self.neurons {
                guard let r = n.stimulate(inputs: inputs)  else { continue }
                outputs.append(r)
            }
            return outputs
        }
    }
    
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
            while true {
                if activationSS >= activators.count { return }
                if weightSS >= weights.count { return }
                if availableLineSS >= adjustedInputCount { availableLineSS = 0 }

                if activators[activationSS] {
                    inputPortDescriptors.append(availableLineSS)
                    inputPorts.append(0)    // Make room for another input
                    weightSS += 1
                }
                availableLineSS += 1; activationSS += 1
            }
        }

        func setThreshold(_ value: Double) { threshold = value }

        func show(tabs: String, override: Bool = false) {
            if Utilities.thereBeNoShowing && !override { return }
            print(tabs + "N. ports = \(inputPortDescriptors.count): \(inputPortDescriptors)")
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
            
            for (weightSS, inputPort) in zip(0..., self.inputPorts) {
                output += inputPort * weights[weightSS]
            }
            
            return output
        }
    }
}
