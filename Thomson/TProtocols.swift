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

// MARK - Builder
protocol ProductProtocol { init() }

protocol TBuilderProtocol {
    associatedtype Product: ProductProtocol

    var completedProduct: [Product] { get set }
    var underConstruction: Product? { get set }

    mutating func beginConstruction()
    mutating func finalizeConstruction()
}

extension TBuilderProtocol {
    mutating func beginConstruction() {
        guard underConstruction == nil else { preconditionFailure("Previous construction not finalized") }
        underConstruction = Product()
    }

    mutating func finalizeConstruction() {
        guard let u = underConstruction else { return }
        completedProduct.append(u)
        underConstruction = nil
    }
}

// MARK - Neuron

protocol TNeuronProtocol: ProductProtocol {
    mutating func activator(_ fn: AFn.FunctionName)
    mutating func bias(_ bias: Double)
    mutating func connector(_ connector: Int)
    mutating func weight(_ weight: Double)
}

// MARK - Neuron builder

protocol TNeuronBuilderProtocol: TBuilderProtocol where Product == TNeuron { }

extension TNeuronBuilderProtocol {
    mutating func activator(_ fn: AFn.FunctionName) { underConstruction!.activator(fn) }
    mutating func bias(_ bias: Double) { underConstruction!.bias(bias) }
    mutating func connector(_ connector: Int) { underConstruction!.connector(connector) }
    mutating func weight(_ weight: Double) { underConstruction!.weight(weight) }
}

// MARK - I think I'm getting the hang of generics

protocol TLayerProtocol: ProductProtocol, TNeuronBuilderProtocol { }
protocol TLayerBuilderProtocol: TBuilderProtocol where Product == TLayer { }
protocol TNetProtocol: ProductProtocol, TLayerBuilderProtocol { }
protocol TNetBuilderProtocol: TBuilderProtocol where Product == TNet { }
