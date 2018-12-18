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
    class Brain: NeuralNetProtocol {
        public var allLayersConnected = true
        var fishNumber = 0
        var net: AKNet?

        func generateRandomSensoryInput() -> [Double] {
            return [0]
        }

        var layers = [Translators.Layer]()
        var underConstruction: Translators.Layer?

        static var count = 0
        init() {
            Brain.count += 1
        }

        deinit { Brain.count -= 1 }

        var firstLayer = true

        func makeLayer() -> Layer {
            return Layer(layerSSInBrain: layers.count)
        }

        func accumulateBias(_ value: Double) { underConstruction?.accumulateBias(value) }

        func addActivator(_ active: Bool) { underConstruction?.addActivator(active) }

        func addWeight(_ value: ValueDoublet) { underConstruction?.addWeight(value) }
        func addWeight(_ baseline: Double, _ value: Double) { underConstruction?.addWeight(baseline, value) }

        func closeLayer() {
            if let u = underConstruction {
                closeNeuron()

                // Just discard empty layers
                if !u.neurons.isEmpty { layers.append(u) }

                underConstruction = nil
            }
        }

        func closeNeuron() { underConstruction?.closeNeuron() }

        func setInputs(_ inputs: [Int]) {

        }

        func endOfStrand() {
            closeNeuron()
            closeLayer()
        }

        func newLayer() {
           precondition(underConstruction == nil)
           underConstruction = makeLayer()
        }

        func newNeuron() { underConstruction?.newNeuron() }

        func setOutputFunction(_ function: @escaping NeuronOutputFunction) { underConstruction?.setOutputFunction(function) }

        func show(tabs: String, override: Bool = false) {
            if Utilities.thereBeNoShowing && !override { return }
            print("Brain: ")
            for layer in layers { layer.show(tabs: "", override: override) }
            print()
        }
    }
}

extension Translators.Brain {
    func stimulate(sensoryInputs: [Double]) -> [Double?] {
        self.net = AKNet(self.layers)
        return self.net!.driveSignal(sensoryInputs)
    }
}
