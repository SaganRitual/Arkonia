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

enum GSComparison: String { case ANY, BE, BT, EQ }

protocol GSFactoryProtocol: class, CustomStringConvertible {
    var genomeWorkspace: String { get set }

    func getAboriginal() -> GSSubjectProtocol
    func makeArkon(genome: Genome, mutate: Bool) -> GSSubjectProtocol?
    func mutate(from: Genome)
}

protocol GSGoalSuiteProtocol: class, CustomStringConvertible {
    var factory: GSFactoryProtocol { get }
    var tester: GSTesterProtocol { get }

    var selectionControls: KSelectionControls { get set }
}

protocol GSSubjectProtocol: class, CustomStringConvertible {
    var fishNumber: Int { get }
    var fitnessScore: Double { get set }
    var genome: Genome { get set }
    var hashedAlready: SetOnce<Int> { get set }
    var spawnCount: Int { get set }
    var suite: GSGoalSuiteProtocol? { get set }

    init()
    func postInit(suite: GSGoalSuiteProtocol)
}

protocol LightLabelProtocol {
    var lightLabel: String { get }
}