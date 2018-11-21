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

protocol BreederFitnessTester {
    func administerTest(to testSubject: BreederTestSubject) -> (Double, String)?
    func getFitnessScore(for outputs: [Double]) -> (Double, String)
}

protocol BreederTestSubjectFactory {
    func makeTestSubject() -> BreederTestSubject
}

protocol BreederTestSubjectAPI {
    func setFitnessTester(_ tester: BreederFitnessTester)
}

protocol BreederTestSubjectProtocol {
    var brain: LayerOwnerProtocol! { get set }
    var myFishNumber: Int { get }
    var genome: Genome! { get set }
    var testScore: Double { get set }
    
    init()
    init(genome: Genome)
    
    static func makeBrain(from genome: Genome) -> LayerOwnerProtocol
    static func makeTestSubject(with genome: Genome?) -> BreederTestSubject
    static func makeTestSubject() -> BreederTestSubject
    func spawn() -> BreederTestSubject?
}

class BreederTestSubject: BreederTestSubjectProtocol {
    static var theFishNumber = 0

    var brain: LayerOwnerProtocol!
    let myFishNumber = BreederTestSubject.theFishNumber
    var genome: Genome!
    var testScore = 0.0
    
    required init() { self.genome = nil }
    required init(genome: Genome) { self.genome = genome }

    class func makeBrain(from genome: Genome) -> LayerOwnerProtocol { fatalError() }
    class func makeTestSubject(with genome: Genome?) -> BreederTestSubject { fatalError() }
    class func makeTestSubject() -> BreederTestSubject { fatalError() }
    func spawn() -> BreederTestSubject? { fatalError() }
}
