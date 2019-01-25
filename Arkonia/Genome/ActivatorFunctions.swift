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

public enum AFn {
    typealias NeuronOutputFunction = (Double) -> Double

   public enum FunctionName: String, CaseIterable {
        case identity, binarystep, logistic, tanh, arctan, softsign, isru, isrlu, sqnl
        case relu, brelu, leakyrelu, boundleakyrelu, prelu, rrelu, elu, selu, srelu, apl, softplus
        case bentidentity, swish, softexponential, softclipping, sinusoid, sinc, gaussian
        case limiter, boundidentity, boundbentidentity, boundsoftplus
    }

    static func bound(_ theFunction: AFn.FunctionName, _ theDouble: Double) -> Double {
        let rawValue = AFn.function[theFunction]!(theDouble)
        let cappedAtPlusOne = min(1.0, rawValue)
        return max(-1, cappedAtPlusOne)
    }

    // We have a bound function only for the functions that might return
    // something outside the range -1 <= x <= 1. No need to bound those that
    // already return in that range.
    static let function: [FunctionName: NeuronOutputFunction] = [
        .arctan : { return atan($0) },
        .binarystep : { return $0 < 0.0 ? 0.0 : 1.0 },
        .gaussian : { return exp(-($0 * $0)) },
        .identity : { return $0 },

        .sinc : { return $0 == 0.0 ? 1.0 : sin($0) / $0 },
        .sinusoid : { return sin($0) },

        .softsign : { return $0 / (1 + abs($0)) },

        .bentidentity : { return ((sqrt($0 * $0 + 1.0) - 1.0) / 2.0) + $0 },
        .boundbentidentity : { return bound(.bentidentity, $0) },

        .boundidentity : { return bound(.identity, $0) },

        .leakyrelu : { return $0 < 0.0 ? (0.01 * $0) : $0 },
        .boundleakyrelu : { return bound(.leakyrelu, $0) },

        .logistic : { return 1.0 / (1.0 + exp(-$0)) },

        .boundsoftplus : { return bound(.softplus, $0) },
        .softplus : { return log(1.0 + exp($0)) },

        .tanh : { return CoreGraphics.tanh($0) },
        .sqnl : {
            if $0 > 2.0 { return 1.0 }
            if $0 >= 0.0 { return $0 - $0 * $0 / 4.0 }
            if $0 >= -2.0 { return $0 + $0 * $0 / 4.0 }
            return -1.0
        }
    ]

    static func getRandomOutputFunction() -> FunctionName {
        return FunctionName.allCases.randomElement()!
    }
}
