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

protocol HasLightLabelProtocol {
    var lightLabel: String { get }
}

protocol GSSubjectProtocol: class, CustomStringConvertible {
    var brain: Translators.Brain { get }
    var fishNumber: Int { get }
    var genome: Genome { get }
    var score: Double { get }
    var results: GSResults { get }

    init(genome: GenomeSlice, brain: Translators.Brain)
}

class GSSubject: GSSubjectProtocol, HasLightLabelProtocol {
    static var theFishNumber = 0

    let brain: Translators.Brain
    let fishNumber: Int
    let genome: Genome
    let results = GSResults()

    public var description: String {
        return "Arkon \(fishNumber) score \(score.sciTruncate(5))"
    }

    public var lightLabel: String { return description + results.lightLabel }

    public var score: Double {
        get { return results.scoreCore.score }
        set { results.scoreCore.score = newValue }
    }

    required init(genome: GenomeSlice, brain: Translators.Brain) {
        self.brain = brain; self.genome = String(genome)
        fishNumber = GSSubject.theFishNumber; GSSubject.theFishNumber += 1
    }
}

extension GSSubject: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.genome)
    }

    static func == (lhs: GSSubject, rhs: GSSubject) -> Bool {
        return lhs.genome == rhs.genome
    }

}
