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

import CoreGraphics // For the math functions
import Foundation

enum AFn {
    typealias NeuronOutputFunction = (Double) -> Double

    enum FunctionName: String {
        case identity, binarystep, logistic, tanh, arctan, softsign, isru, isrlu, sqnl
        case relu, brelu, leakyrelu, prelu, rrelu, elu, selu, srelu, apl, softplus
        case bentidentity, swish, softexponential, softclipping, sinusoid, sinc, gaussian
        case limiter, boundidentity, boundbentidentity
    }

    static let lookup: [FunctionName: NeuronOutputFunction] = [
        .arctan: arctan,
        .bentidentity: bentidentity,
        .boundbentidentity: boundbentidentity,
        .boundidentity: boundidentity,
        .boundleakyrelu: boundleakyrelu,
        .boundsoftplus: boundsoftplus,
        .binarystep: binarystep,
        .gaussian: gaussian,
        .identity: identity,
        .leakyrelu: leakyrelu,
        .logistic: logistic,
        .sinc: sinc,
        .sinusoid: sinusoid,
        .softplus: softplus,
        .softsign: softsign,
        .sqnl: sqnl,
        .tanh: tanh
    ]

    static func bound(_ theDouble: Double) -> Double {
        let cappedAtPlusOne = min(1.0, theDouble)
        return max(-1, cappedAtPlusOne)
    }

    // We have a bound function only for the functions that might return
    // something outside the range -1 <= x <= 1. No need to bound those that
    // already return in that range.
    static func arctan(_ x: Double) -> Double { return atan(x) }

    static func binarystep(_ x: Double) -> Double { return x < 0.0 ? 0.0 : 1.0 }
    static func gaussian(_ x: Double) -> Double { return exp(-(x * x)) }
    static func identity(_ x: Double) -> Double { return x }

    static func sinc(_ x: Double) -> Double { return x == 0.0 ? 1.0 : sin(x) / x }
    static func sinusoid(_ x: Double) -> Double { return sin(x) }

    static func softsign(_ x: Double) -> Double { return x / (1 + abs(x)) }

    static func bentidentity(_ x: Double) -> Double { return ((sqrt(x * x + 1.0) - 1.0) / 2.0) + x }
    static func boundbentidentity(_ x: Double) -> Double { return bound(bentidentity(x)) }

    static func boundidentity(_ x: Double) -> Double { return bound(identity(x)) }
    static func leakyrelu(_ x: Double) -> Double { return x < 0.0 ? (0.01 * x) : x }

    static func boundleakyrelu(_ x: Double) -> Double { return bound(leakyrelu(x)) }
    static func logistic(_ x: Double) -> Double { return 1.0 / (1.0 + exp(-x)) }

    static func boundsoftplus(_ x: Double) -> Double { return bound(softplus(x)) }
    static func softplus(_ x: Double) -> Double { return log(1.0 + exp(x)) }

    static func sqnl(_ x: Double) -> Double {
        if x > 2.0 { return 1.0 }
        if x >= 0.0 { return x - x * x / 4.0 }
        if x >= -2.0 { return x + x * x / 4.0 }
        return -1.0
    }

    static func tanh(_ x: Double) -> Double { return CoreGraphics.tanh(x) }

    static func getRandomOutputFunction() -> String {
        return FunctionName.init(rawValue: lookup.keys.randomElement()<!>.rawValue)!.rawValue
    }

    static func setOutputFunction(_ functionName_: String, for brain: Translators.Brain) {
        if functionName_.isEmpty { preconditionFailure("No function name") }

        guard let functionName = FunctionName.init(rawValue: functionName_)
            else { preconditionFailure("Function name not found") }

        brain.setOutputFunction(lookup[functionName]!)
    }

}
