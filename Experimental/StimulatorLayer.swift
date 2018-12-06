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

let theNeurons = [
    Stimulators.Neuron(ssInLayer: 42, activators: activators, weights: weights0a, bias: 5.0),
    Stimulators.Neuron(ssInLayer: 43, activators: activators, weights: weights0a, bias: 10.0),
    Stimulators.Neuron(ssInLayer: 44, activators: activators, weights: weights0b, bias: 9.0),
    Stimulators.Neuron(ssInLayer: 45, activators: activators, weights: weights0a, bias: 10.0),
    Stimulators.Neuron(ssInLayer: 46, activators: activators, weights: weights0b, bias: 9.0),
    Stimulators.Neuron(ssInLayer: 47, activators: activators, weights: weights0a, bias: 5.0),
    Stimulators.Neuron(ssInLayer: 48, activators: activators, weights: weights0b, bias: 9.0),
    Stimulators.Neuron(ssInLayer: 49, activators: activators, weights: weights0a, bias: 5.0),
    Stimulators.Neuron(ssInLayer: 50, activators: activators, weights: weights0a, bias: 10.0),
    Stimulators.Neuron(ssInLayer: 51, activators: activators, weights: weights0b, bias: 9.0),
    Stimulators.Neuron(ssInLayer: 52, activators: activators, weights: weights0a, bias: 10.0),
    Stimulators.Neuron(ssInLayer: 53, activators: activators, weights: weights0b, bias: 9.0),
    Stimulators.Neuron(ssInLayer: 54, activators: activators, weights: weights0a, bias: 5.0),
    Stimulators.Neuron(ssInLayer: 55, activators: activators, weights: weights0b, bias: 9.0),
]
var neuronCounter = 0

extension Stimulators {
    class Layer: CustomStringConvertible {
        private var neurons = [Neuron]()
        private let layerSSInBrain: Int
        private var totalOutput: Double?
        
        var description: String { return "Layer \(layerSSInBrain)" }
        
        init(layerSSInBrain: Int) {
            self.layerSSInBrain = layerSSInBrain
            
            for _ in 0..<3 {
                neurons.append(theNeurons[neuronCounter])
                neuronCounter += 1
            }
        }

        public func stimulate(inputsFromPreviousLayer: [Double?]) -> [Double?] {
            if inputsFromPreviousLayer.compactMap({$0}).isEmpty
                { return inputsFromPreviousLayer }
            
            var inputsForNextLayer = Array(inputsFromPreviousLayer)
            
            for (whichNeuron, neuron) in zip(0..., neurons) {
                let neuronOutputs = neuron.stimulate(inputSources: inputs)
                
                let neuronSubtotal =
                    neuronOutputs.compactMap({$0}).reduce(0.0, +)
                
                inputsForNextLayer[whichNeuron] = neuronSubtotal + neuron.bias
            }
            
            return inputsForNextLayer
        }
    }
}
