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

class TSRandomOutputs: BreederTestSubject {
    class TSF: BreederTestSubjectFactory {
        func makeTestSubject() -> BreederTestSubject {
            return TSRandomOutputs.makeTestSubject()
        }
    }
    
    override init() { super.init() }
    override init(genome: Genome) { super.init(genome: genome) }
    override init(genome: Genome, int: Int) {  }

    override class func makeTestSubject() -> BreederTestSubject {
        return TSRandomOutputs(genome: Genome(), Int.random(in: -10000...10000))
    }
    
    class func setBreederTestSubjectFactory() {
        _ = Breeder.bb.setTestSubjectFactory(TSF())
    }
    
    override func spawn() -> BreederTestSubject? {
        return TSRandomOutputs.makeTestSubject()
    }
}

class FTRandomOutputs: BreederFitnessTester {
    func getFitnessScore(for outputs: [Double]) -> (Double, String) {
        return (0, "This stub seems a bit ugly")
    }
    
    func administerTest(to testSubject: BreederTestSubject) -> (Double, String)? {
        let d = Double((testSubject as! TSRandomOutputs).myFishNumber)
        return (abs(d), "I have nothing to say")
    }
}
