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

struct VNeuronActivator: NeuronActivatorProtocol {
    var value: AFn.FunctionName
    init(_ value: AFn.FunctionName) { self.value = value }
}

struct VNeuronBias: NeuronBiasProtocol {
    var value: Double
    init(_ value: Double) { self.value = value }
}

struct VNeuronDownConnector: NeuronDownConnectorProtocol {
    var value: Int
    init(_ value: Int) { self.value = value }
}

struct VNeuronUpConnector: NeuronUpConnectorProtocol {
    var value: UpConnectorProtocol
    init(_ value: UpConnectorProtocol) { self.value = value }
}

final class VTNeuron: TNeuron {
    func setActivator(_ a: AFn.FunctionName) {
        super.setActivator(VNeuronActivator(a))
    }

    func accumulateBias(_ b: Double) { super.bias += b }
    func addDownConnector(_ c: Int) { super.downConnectors.append(c) }
    func addUpConnector(_ c: UpConnector) { super.upConnectors.append(c) }
}
