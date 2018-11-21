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

class TSNumberGuesser: BreederTestSubject {
    class TSF: BreederTestSubjectFactory {
        let genome: Genome?

        init() {
            Translators.numberOfSenses = 1
            Translators.numberOfMotorNeurons = 1
            genome = nil
        }
        
        init(genome: Genome) { self.genome = genome }

        func makeTestSubject() -> BreederTestSubject {
            if let g = genome {
                return TSNumberGuesser(genome: g, brain: nil)
            }
            
            // Random genome, as of 19Nov2018
            return TSNumberGuesser.makeTestSubject()
        }
    }
    
    private init(genome: Genome?, brain: LayerOwnerProtocol?) {
        if let g = genome {
            super.init(genome: g)

            if let b = brain { self.brain = b }
            else { self.brain = TSLearnZoeName.makeBrain(from: g) }
            
            return
        }
        
        super.init()
        self.genome = RandomnessGenerator.generateRandomGenome()
        self.brain = TSLearnZoeName.makeBrain(from: self.genome)
    }

    class func makeTestSubject(with genome: Genome) -> BreederTestSubject{
        TSNumberGuesser.theFishNumber += 1
        return TSNumberGuesser(genome: genome, brain: nil)
    }

    override class func makeTestSubject() -> BreederTestSubject {
        return TSNumberGuesser(genome: nil, brain: nil)
    }
    
    class func setBreederTestSubjectFactory() {
        _ = Breeder.bb.setTestSubjectFactory(TSF())
    }
    
    override func spawn() -> BreederTestSubject? {
        return TSNumberGuesser.makeTestSubject()
    }
}

class FTNumberGuesser: BreederFitnessTester {
    func administerTest(to testSubject: BreederTestSubject) -> (Double, String)? {
        let ts = testSubject as! TSNumberGuesser
        let sensoryInput: [Double] = [1]
        guard let outputs = ts.brain.stimulate(inputs: sensoryInput) else { return nil }
        
        return getFitnessScore(for: outputs)
    }
    
    internal func getFitnessScore(for outputs: [Double]) -> (Double, String) {
        let score = abs(outputs.reduce(0, +) - 3)
        return (score, "New best score \(score.sTruncate())")
    }
}

