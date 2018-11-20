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
    func administerTest(to testSubject: BreederTestSubject) -> Double?
}

protocol BreederTestSubjectFactory {
    func makeTestSubject() -> BreederTestSubject
}

protocol BreederTestSubjectAPI {
    func setFitnessTester(_ tester: BreederFitnessTester)
}

protocol BreederTestSubjectProtocol {
    static func makeTestSubject() -> BreederTestSubject
    func spawn() -> BreederTestSubject
}

class BreederTestSubject {
    class func makeTestSubject() -> BreederTestSubject { fatalError() }
    func spawn() -> BreederTestSubject { fatalError() }
}

class BreederTestZoeBrain: BreederTestSubject {
    var brain: LayerOwnerProtocol!
    var genome: Genome!
    
    static var theFishNumber = 0
    let myFishNumber = BreederTestZoeBrain.theFishNumber
    
    class TSF: BreederTestSubjectFactory {
        let genome: Genome?

        init() { self.genome = nil }
        init(genome: Genome) { self.genome = genome }
        
        func makeTestSubject() -> BreederTestSubject {
            if let g = genome {
                return BreederTestZoeBrain(genome: g, brain: nil)
            }
            
            // Random genome, as of 19Nov2018
            return BreederTestZoeBrain.makeTestSubject()
        }
    }

    private init(genome: Genome?, brain: LayerOwnerProtocol?) {
        if let g = genome {
            self.genome = g
            if let b = brain { self.brain = b }
            else { self.brain = BreederTestZoeBrain.makeBrain(from: g) }
            
            return
        }
        
        self.genome = RandomnessGenerator.generateRandomGenome()
        self.brain = BreederTestZoeBrain.makeBrain(from: self.genome)
    }
    
    static func makeBrain(from genome: Genome) -> LayerOwnerProtocol {
        Decoder.d.setInput(to: genome).decode()
        return Translators.t.getBrain()
    }
    
    override class func makeTestSubject() -> BreederTestSubject {
        BreederTestZoeBrain.theFishNumber += 1
        return BreederTestZoeBrain(genome: nil, brain: nil)
    }
    
    class func makeTestSubject(with genome: Genome) -> BreederTestSubject{
        BreederTestZoeBrain.theFishNumber += 1
        return BreederTestZoeBrain(genome: genome, brain: nil)
    }
    
    class func setBreederTestSubjectFactory() {
        _ = Breeder.bb.setTestSubjectFactory(TSF())
    }
    
    override func spawn() -> BreederTestSubject {
        _ = Mutator.m.setInputGenome(genome).mutate()
        let mutatedGenome = Mutator.m.convertToGenome()
        let brain = BreederTestZoeBrain.makeBrain(from: mutatedGenome)
        return BreederTestZoeBrain(genome: mutatedGenome, brain: brain)
    }
}

class BreederTestSubjectMockBrain: BreederTestSubject {
    class TSF: BreederTestSubjectFactory {
        func makeTestSubject() -> BreederTestSubject {
            return BreederTestSubjectMockBrain.makeTestSubject()
        }
    }
    
    var myFishNumber = 0
    
    override class func makeTestSubject() -> BreederTestSubject {
        return BreederTestSubjectMockBrain()
    }
    
    class func setBreederTestSubjectFactory() {
        _ = Breeder.bb.setTestSubjectFactory(TSF())
    }
    
    override func spawn() -> BreederTestSubject {
        let n = BreederTestSubjectMockBrain.makeTestSubject() as! BreederTestSubjectMockBrain
        n.myFishNumber = Int.random(in: -10000...10000)
        return n
    }
}

class MockBrainFitnessTester: BreederFitnessTester {
    func administerTest(to testSubject: BreederTestSubject) -> Double? {
        let d = Double((testSubject as! BreederTestSubjectMockBrain).myFishNumber)
        return abs(d)
    }
}

class ZoeBrainFitnessTester: BreederFitnessTester {
    let zName = "Zoe Bishop"
    let uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ "
    let lowercase = "abcdefghijklmnopqrstuvwxyz "

    func administerTest(to testSubject: BreederTestSubject) -> Double? {
        let ts = testSubject as! BreederTestZoeBrain
        let sensoryInput: [Double] = [1, 1, 1, 1, 1]
        guard let outputs = ts.brain.stimulate(inputs: sensoryInput) else { return nil }
        
        return getFitnessScore(for: outputs)
    }
    
    func displayZoeMatch(outputs: [Double]) -> [Double] {
        
        var zIndex = zName.startIndex
        for output in outputs {
            let zSlice = zName[zIndex...]
            let zChar = zSlice.first!
            
            let chopped = Int(output.remainder(dividingBy: 27.0).rounded())
            if chopped < 0 { print("chopped = \(chopped)"); raise(SIGINT) }
            let isUppercase = String().isUppercase(zChar)
            let whichCase = isUppercase ? uppercase : lowercase
            let characterIndex = whichCase.index(whichCase.startIndex, offsetBy: chopped)
            print(whichCase[characterIndex], terminator: "")
            
            zIndex = zName.index(after: zIndex)
        }
        
        return []
    }
    
    private func getFitnessScore(for outputs: [Double]) -> Double {
        var scoreForTheseOutputs = 0.0
        
        var matchIndex: String.Index!
        var whichCase = uppercase
        
        for character in zName {
            if character == " " {
                whichCase = "ADisgustingHackThatIShouldBePuni shed for"
                matchIndex = whichCase.firstIndex(of: character)!
            } else if String().isUppercase(character) {
                matchIndex = uppercase.firstIndex(of: character)!
                whichCase = uppercase
            } else {
                matchIndex = lowercase.firstIndex(of: character)!
                whichCase = lowercase
            }
            
            let s = whichCase.distance(from: whichCase.startIndex, to: matchIndex)
            scoreForTheseOutputs += Double(s)
        }
        
        return scoreForTheseOutputs
    }
}
