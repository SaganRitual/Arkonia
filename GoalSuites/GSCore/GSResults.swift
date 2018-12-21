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

protocol GSResultsProtocol: class, CustomStringConvertible {
    associatedtype OutputType: Numeric

    var actualOutput: Double { get }
    var expectedOutput: Double { get }
    var fitnessScore: Double { get }
    var scoreCore: GSScore { get set }
    var sensoryInput: [Double] { get set }
    var spawnCount: Int { get }

    func passesCompare(_ op: GSGoalSuite.Comparison, against rhs: GSSubject) -> Bool
    func report()
    func setTestResults(_ score: Double, _ expectedOutput: Double, _ actualOutput: Double)
}

class GSScore: CustomStringConvertible, Hashable {
    var score = 0.0

    public var description: String {
        return score.sTruncate()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(score)
    }

    static func == (_ lhs: GSScore, _ rhs: GSScore) -> Bool { return lhs.score == rhs.score }
}

class GSResults: GSResultsProtocol, LightLabelProtocol {
    typealias OutputType = Double

    var actualOutput = OutputType()
    var expectedOutput = OutputType()
    var sensoryInput = [Double]()
    var scoreCore = GSScore()
    var spawnCount: Int = 0

    var description: String {
        return "Expected \(expectedOutput), actual \(actualOutput), " +
                "score \(scoreCore), spawnCount \(spawnCount)"
    }

    var lightLabel: String {
        return ", guess: \(actualOutput.sciTruncate(5))"
    }

    var fitnessScore: Double {
        get { return scoreCore.score }
        set { scoreCore.score = newValue }
    }

    func passesCompare(_ op: GSGoalSuite.Comparison, against rhs: GSSubject) -> Bool {
        switch op {
        case .BE: return fitnessScore <= rhs.results.fitnessScore
        case .BT: return fitnessScore < rhs.results.fitnessScore
        case .EQ: return fitnessScore == rhs.results.fitnessScore
        }
    }

    public func report() {

    }

    func setTestResults(_ score: Double, _ expectedOutput: Double, _ actualOutput: Double) {
        self.scoreCore.score = score; self.expectedOutput = expectedOutput
        self.actualOutput = actualOutput
    }

    static func <= (lhs: Double, rhs: GSResults) -> Bool {
        return lhs < rhs.fitnessScore || lhs == rhs.fitnessScore
    }

    static func < (lhs: Double, rhs: GSResults) -> Bool { return lhs < rhs.fitnessScore }
    static func == (lhs: Double, rhs: GSResults) -> Bool { return lhs == rhs.fitnessScore }
}
