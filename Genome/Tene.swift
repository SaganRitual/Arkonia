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
    // The components are the results of a regex. For each tene,
    // we get the submatches from this array, which represent
    // the token and the value, respectively.
    let token: GenomeSlice
    var value: String
    var baseline: String

    var description: String {
        let L = Manipulator.lay_s
        let N = Manipulator.neu_s
        if token == L || token == N { return "MarkerGene: \(token)" }
        else { return "\(token) gene: \(value) baseline: \(baseline)" }
    }

    init(_ token: GenomeSlice, value: String, baseline: String = "") {
        self.token = token; self.value = value; self.baseline = baseline
    }

    func mutate() {
        if [Manipulator.lay_s, Manipulator.neu_s, Manipulator.ifm_s].contains(self.token) { return }

        if [Manipulator.bis_s].contains(self.token) {
            let b = Mutator.m.mutate(from: Double(self.value)!)
            self.value = String(b.dTruncate())
            return
        }

        if self.value == "true" || self.value == "false" {
            self.value = String(Bool.random()); return
        }

        // A rather ugly way of finding out whether we're an F tene.
        if let functionName = AFn.FunctionName(rawValue: self.value),
            AFn.lookup[functionName] != nil {

            self.value = AFn.getRandomOutputFunction(); return
        }

        let b = Mutator.m.mutate(from: Double(self.baseline)!)
        self.baseline = String(b.dTruncate())

        // In case anyone gets stuck at zero
        if Double(self.baseline)! == 0.0 { self.baseline = (1.0).sTruncate() }

        let v = Mutator.m.mutate(from: self.value)
        if abs(v) < abs(b) { self.value = self.baseline }
        else { self.value = String(v.dTruncate()) }

        //        print("mf \(self.value) -> \(v)")
    }
}
