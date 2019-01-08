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

typealias Tenome = [Tene]
typealias Tegment = ArraySlice<Tene>

class Tene: CustomStringConvertible {
    let token: GenomeSlice
    var baseValue: String
    var secondaryValue: String

    var description: String {
        if token == Manipulator.sLay || token == Manipulator.sNeu { return "MarkerGene: \(token)" }
        else { return "\(token) weight: \(baseValue) channel: \(secondaryValue)" }
    }

    init(_ token: GenomeSlice, baseValue: String, secondaryValue: String = "") {
        self.token = token; self.baseValue = baseValue; self.secondaryValue = secondaryValue
    }

    func mutate() {
        // Layer and Neuron are void genes
        if [Manipulator.sLay, Manipulator.sNeu].contains(self.token) { return }

        // Bias is a Double
        if [Manipulator.sBis].contains(self.token) {
            let b = ArkonCentral.mut.mutate(from: Double(self.baseValue)!)
            self.baseValue = String(b.dTruncate())
            return
        }

        // Down connector is an Int
        if [Manipulator.sDnc].contains(self.token) {
            let d = ArkonCentral.mut.mutate(from: Int(self.baseValue)!)
            self.baseValue = String(d)
            return
        }

        // Activator function
        if let functionName = AFn.FunctionName(rawValue: self.baseValue),
            AFn.lookup[functionName] != nil {
            self.baseValue = AFn.getRandomOutputFunction()
            return
        }

        // Up connector is an UpConnector
        if [Manipulator.sUpc].contains(self.token) {
            let weight = ArkonCentral.mut.mutate(from: Double(self.baseValue)!)
            let channel = ArkonCentral.mut.mutate(from: Int(self.secondaryValue)!)

            self.baseValue = String(weight.dTruncate())
            self.secondaryValue = String(channel)
            return
        }

        preconditionFailure("Didn't expect to see me here")
    }
}
