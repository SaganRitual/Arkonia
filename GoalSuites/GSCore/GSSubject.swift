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

protocol LightLabelProtocol {
    var lightLabel: String { get }
}

protocol GSSubjectProtocol: class, CustomStringConvertible {
    var fitnessScore: Double { get }
    func postInit(suite: GSGoalSuite)
}

class GSSubject: GSSubjectProtocol, LightLabelProtocol {
    static var theFishNumber = 0

    let brain: Translators.Brain
    let fishNumber: Int
    let genome: Genome
    var scoreCore = GSScore()
    var spawnCount: Int = 0
    var suite: GSGoalSuite?

    public var description: String {
        return "Arkon \(fishNumber) score \(fitnessScore.sciTruncate(5))"
    }

    public var lightLabel: String {
        return description + "Inputs: (something), outputs (smetghing else)" }

    public var fitnessScore: Double {
        get { return scoreCore.score }
        set { scoreCore.score = newValue }
    }

    init(genome: GenomeSlice, brain: Translators.Brain) {
        fishNumber = GSSubject.theFishNumber; GSSubject.theFishNumber += 1

        self.brain = brain; self.genome = String(genome)
        brain.fishNumber = self.fishNumber
    }

    func postInit(suite: GSGoalSuite) { self.suite = suite }
}

extension GSSubject: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.genome)
    }

    static func == (lhs: GSSubject, rhs: GSSubject) -> Bool {
        return lhs.genome == rhs.genome
    }

    static func <= (lhs: Double, rhs: GSSubject) -> Bool {
        return lhs < rhs.fitnessScore || lhs == rhs.fitnessScore
    }

    static func < (lhs: Double, rhs: GSSubject) -> Bool { return lhs < rhs.fitnessScore }
    static func == (lhs: Double, rhs: GSSubject) -> Bool { return lhs == rhs.fitnessScore }

}
