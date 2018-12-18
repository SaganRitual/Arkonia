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

protocol CBNeuronBuilderAPI: class {
    func accumulateBias(_ value: Double)
    func addActivator(_ active: Bool)
    func addWeight(_ value: ValueDoublet)
    func addWeight(_ baseline: Double, _ value: Double)
    func setOutputFunction(_ function: @escaping NeuronOutputFunction)
}

protocol CBNeuronDebugProtocol: class, CustomStringConvertible {
    var description: String { get }
    var layerSSInBrain: Int { get }
    var neuronSSInLayer: Int { get }

    func show(tabs: String, override: Bool)
}

protocol CBNeuronSignalProtocol: class {
    var commLinesUsed: [Int] { get }
    var myTotalOutput: Double? { get }

    func driveSignal(upperNeuron: CBNeuronSignalProtocol) -> CBNeuronResults?
}

struct CBNeuronResults {
    var totalOutput: Double
    var commLinesUsed: [CBNeuron]
}
