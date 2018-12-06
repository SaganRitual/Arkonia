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

extension Stimulators {
    class Neuron: CustomStringConvertible {
        private var activators = [Bool]()
        public let bias: Double
        private let layerSSInBrain: Int
        private let ssInLayer: Int
        private var weights = [Double]()
        
        public var description: String {
            return "N(\(layerSSInBrain):\(ssInLayer)): "
        }
        
        init(layerSSInBrain: Int, ssInLayer: Int, activators: [Bool], weights: [Double], bias: Double) {
            self.layerSSInBrain = layerSSInBrain
            self.ssInLayer = ssInLayer
            self.activators = activators
            self.weights = weights
            self.bias = bias
        }
        
        private func computeOutput(for inputs: [Double?]) -> [Double?] {
            var commLine = 0
            var outputSansBias: [Double?] = Array(repeating: nil, count: inputs.count)
            
            for activator in activators {
                defer {
                    repeat {
                        commLine = (commLine + 1) % inputs.count
                    } while inputs[commLine] == nil
                }
                
                if activator && !weights.isEmpty {
                    guard let inputValue = inputs[commLine]
                        else { preconditionFailure("We're not supposed to get nil from the above loop") }
                    
                    outputSansBias[commLine] = (outputSansBias[commLine] ?? 0.0) + weights.pop() * inputValue
                }
            }
            
            return outputSansBias
        }

        func report(inputs: [Double?], outputs: [Double?]) {
            print("\tNeuron \(ssInLayer) report: ", terminator: "")
            print(bias, inputs, outputs)
        }
        
        func stimulate(inputSources: [Double?]) -> [Double?] {
            return computeOutput(for: inputSources)
        }
    }
}
