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
    var underConstruction: Neuron?

    var layerSSInBrain = 0

    var description: String { return "Layer(\(self.layerSSInBrain))" }

    private static var count = 0
    init(layerSSInBrain: Int) {
        Layer.count += 1
        self.layerSSInBrain = layerSSInBrain
    }

    deinit { Layer.count -= 1 }

    func accumulateBias(_ value: Double) { underConstruction?.accumulateBias(value) }

    func addActivator(_ active: Bool) { underConstruction?.addActivator(active) }

    func addWeight(_ value: ValueDoublet) { underConstruction?.addWeight(value) }
    func addWeight(_ baseline: Double, _ value: Double) { underConstruction?.addWeight(baseline, value) }

    func closeNeuron() { if let u = underConstruction { neurons.append(u) }; underConstruction = nil }

    func endOfStrand() { neurons.forEach { $0.endOfStrand() } }

    private func makeNeuron() -> Neuron {
        return Neuron(layerSSInBrain: self.layerSSInBrain, neuronSSInLayer: neurons.count)
    }

    func newNeuron() {
        precondition(underConstruction == nil)
        underConstruction = makeNeuron()
    }

    func setOutputFunction(_ function: @escaping NeuronOutputFunction) { underConstruction?.setOutputFunction(function) }

    func show(tabs: String, override: Bool = false) {
        if Utilities.thereBeNoShowing && !override { return }
        print("\n\tL.\n\(tabs)")
        for neuron in neurons {
            neuron.show(tabs: tabs + "", override: override)
        }
    }
}

}

extension Translators.Layer {

    public func markActiveLines(_ activeCommLines: [Int]) {
        activeCommLines.forEach { neurons[$0].hasClients = true }
    }

    public func stimulate(inputsFromPreviousLayer: [Double?]) -> ([Double?], [Int]) {
        if inputsFromPreviousLayer.compactMap({$0}).isEmpty
            { return (inputsFromPreviousLayer, []) }

        var commLinesUsed = Set<Int>()
        var inputsForNextLayer: [Double?] = Array(repeating: nil, count: neurons.count)

        for (whichNeuron, neuron) in zip(0..., neurons) {
            guard let neuronOutput = neuron.stimulate(inputSources: inputsFromPreviousLayer)
                else { continue }

            neuron.commLinesUsed.forEach { commLinesUsed.insert($0) }

            neuron.myTotalOutput = neuronOutput + neuron.bias

            inputsForNextLayer[whichNeuron] = neuron.myTotalOutput
//            print("N(\(layerSSInBrain):\(neuron.neuronSSInLayer))")
        }

        return (inputsForNextLayer, Array(commLinesUsed))
    }

}
