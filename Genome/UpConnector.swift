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

struct UpConnectorChannel: Equatable {
    let channel: Int
    let topOfRange: Int
}

struct UpConnectorWeight: Equatable {
    let weight: Double
}

struct UpConnectorAmplifier: Equatable {
    enum AmplificationMode: CaseIterable { case none, reduce, increase }

    let amplificationMode: AmplificationMode
    let multiplier: Double

    public func amplified(_ input: Double) -> Double {
        switch amplificationMode {
        case .increase: return input
        case .none:     return input
        case .reduce:   return input // / multiplier
        }
    }
}

public typealias UpConnectorValue = (channel: Int, weight: Double)

protocol NeuronUpConnectorProtocol {
    var channel: UpConnectorChannel { get }
    var weight: UpConnectorWeight { get }
    var amplifier: UpConnectorAmplifier { get }
}

struct UpConnector: CustomStringConvertible, NeuronUpConnectorProtocol {
    let channel: UpConnectorChannel
    let weight: UpConnectorWeight
    let amplifier: UpConnectorAmplifier

    public var description: String {
        return "(w[\(weight.weight)]c[\(channel.channel)])"
    }

    init(_ channel: UpConnectorChannel, _ weight: UpConnectorWeight,
         _ amplifier: UpConnectorAmplifier)
    {
        self.channel = channel
        self.weight = weight
        self.amplifier = amplifier
    }
}
