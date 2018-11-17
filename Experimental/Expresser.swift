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

class Expresser: ExpresserProtocol {
    public static var e = Expresser()
    
    let numberOfSenses = 5
    
    var layers = [Expresser.Layer]()
    var reachedEndOfStrand = false
    var underConstruction: Expresser.Layer!
    
    func addActivator(_ active: Bool) { underConstruction.underConstruction.addActivator(active) }
    func addWeight(_ weight: Double) { underConstruction.underConstruction.addWeight(weight) }
    
    func closeLayer() {
        if let u = underConstruction { layers.append(u) }
        underConstruction = nil

        let layer = layers[layers.count - 1]
        let thereIsAPreviousLayer = layers.count >= 2
        var connectionsAvailable = 0
        var start = 0, end = 0

        if thereIsAPreviousLayer {
            connectionsAvailable = layers[layers.count - 2].neurons.count
            start = 0; end = connectionsAvailable
        } else {
            connectionsAvailable = numberOfSenses
            start = numberOfSenses; end = numberOfSenses
        }

        layer.close(inputLineDescriptor: start..<end, iAmBottomLayer: reachedEndOfStrand)
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
        
        func show(override: Bool = false) {
            if Utilities.thereBeNoShowing && !override { return }

            print("Brain:")
            for (ss, layer) in zip(0..., layers) { layer.show(ss) }
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
        
        func close(inputLineDescriptor: Range<Int>, iAmBottomLayer: Bool) {
            var start = 0, end = 0
            for (n, ss) in zip(neurons, 0...) {
                if inputLineDescriptor.isEmpty {
                    start = ss; end = ss
                } else {
                    start = 0; end = inputLineDescriptor.endIndex
                }
                
                let finalRange = start..<end
                n.postInit(inputLineDescriptor: finalRange, inBottomLayer: iAmBottomLayer)
            }
        }

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
            
            for (theSwitch, inputLineSS) in zip(inputLineSwitches, 0..<inputLines.count) {
                inputLines[inputLineSS] = inputs[theSwitch]
            }
            print("stimulate on lines \(inputLines), input values \(inputs)")
            return self.output()
        }

        func postInit(inputLineDescriptor: Range<Int>, inBottomLayer: Bool = false) {
            print("A")
            if activators.isEmpty || weights.isEmpty { return }
            print("B")
            let length = min(activators.count, weights.count)

            let aSlice = activators[0..<length]
            
            // if all the activators are false, there's no
            // point us being in here; none of the weights
            // will work
            if !aSlice.reduce(false, { $0 || $1 }) { return }
            print("C")

            // This happens only for the top layer. We give one
            // sensory input to each neuron, whether he likes it or not.
            // We get a zero-length range with the end index set
            // to the subscript of the sensory input that will
            // apply to this neuron.
            if inputLineDescriptor.isEmpty {
                print("D")
                let theOnlyInputLine = inputLineDescriptor.endIndex
                inputLineSwitches = [theOnlyInputLine]
                inputLines = [0]
                return
            }
            
            print("E")
            // This happens only at the bottom. We have all the bottom
            // neurons set up with one input only, to connect to some
            // neuron in the penultimate layer. But it's boring if they
            // all always go to the leftmost neuron, just because we're
            // counting sequentially.
            if inBottomLayer {
                print("F")
                let inputLineOverride = Int.random(in: inputLineDescriptor)
                inputLineSwitches.append(inputLineOverride)
                print("inputLineOverride: \(inputLineOverride), inputLineDescriptor: \(inputLineDescriptor)")
                return
            }
            print("G")

            var maxInputLines = min(self.weights.count, inputLineDescriptor.count)
            maxInputLines = min(maxInputLines, self.activators.count)
            
            var activatorSS = 0, weightSS = 0, inputLineSS = 0, connectionNumber = 0
            while true {
                if activatorSS >= activators.count { break }
                if weightSS >= weights.count { break }
                if inputLineSS > inputLines.count { break }
                if connectionNumber >= inputLineDescriptor.endIndex { connectionNumber = 0 }
                
                if activators[activatorSS] {
                    self.inputLineSwitches.append(inputLineSS)
                    // We consume a weight and an input line when
                    // we make a connection
                    weightSS += 1; inputLineSS += 1
                }
                
                // We always consume an activator, and we always
                // advance and wrap on the connection numbers array
                activatorSS += 1; connectionNumber += 1
            }
        }

        func setBias(_ value: Double) { bias = value }
        func setThreshold(_ value: Double) { threshold = value }
        
        func show(_ neuronSS: Int) {
            print("Neuron \(neuronSS): inputs on lines \(inputLines)")
            
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
        let biased = ws + b
        let abiased = abs(biased)
        
        let sign = (biased >= 0) ? 1.0 : -1.0
        
        // Make the same sign as ws + b, so we'll trigger on
        // the magnitude. Otherwise, we would send out the
        // threshold value with the wrong sign if ws + b
        // were negative but could trigger t by having a
        // large magnitude.
        return (abiased < abs(t)) ? biased : sign * t
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
