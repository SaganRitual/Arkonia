////
//// Permission is hereby granted, free of charge, to any person obtaining a
//// copy of this software and associated documentation files (the "Software"),
//// to deal in the Software without restriction, including without limitation
//// the rights to use, copy, modify, merge, publish, distribute, sublicense,
//// and/or sell copies of the Software, and to permit persons to whom the
//// Software is furnished to do so, subject to the following conditions:
////
//// The above copyright notice and this permission notice shall be included in
//// all copies or substantial portions of the Software.
////
//// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//// IN THE SOFTWARE.
////
//
//import Foundation
//
//class CustodianTest {
//    class TSF: BreederTestSubjectFactory {
//        let genome: Genome?
//        
//        init(genome: Genome, numberOfSenses: Int = 5, numberOfMotorNeurons: Int = 5,
//             numberOfGenerations: Int = 50, numberOfTestSubjectsPerGeneration: Int = 50) {
//            Translators.numberOfSenses = numberOfSenses
//            Translators.numberOfMotorNeurons = numberOfMotorNeurons
//            Breeder.howManyGenerations = numberOfGenerations
//            Breeder.howManyTestSubjectsPerGeneration = numberOfTestSubjectsPerGeneration
//            self.genome = genome
//        }
//        
//        func makeTestSubject() -> BreederTestSubject {
//            if let g = genome {
//                return TSMockTestSubject.makeTestSubject(with: g)
//            }
//            
//            // Random genome, as of 19Nov2018
//            return TSMockTestSubject.makeTestSubject()
//        }
//    }
//    
//    func runTest() {
//        let genome = "L_N_A(true)_W(b[10.10]v[111.11])_"
//        let ts = BreederTestSubject(genome: genome)
//        let custodian = Custodian(ts)
//        custodian.setFitnessTester(FTMockFitnessTester())
//        _ = custodian.select()
//    }
//}
//
//#if false
//class GenerationTest {
//    class TSF: BreederTestSubjectFactory {
//        let genome: Genome?
//        
//        init(genome: Genome, numberOfSenses: Int = 5, numberOfMotorNeurons: Int = 5,
//             numberOfGenerations: Int = 50, numberOfTestSubjectsPerGeneration: Int = 50) {
//            Translators.numberOfSenses = numberOfSenses
//            Translators.numberOfMotorNeurons = numberOfMotorNeurons
//            Breeder.howManyGenerations = numberOfGenerations
//            Breeder.howManyTestSubjectsPerGeneration = numberOfTestSubjectsPerGeneration
//            self.genome = genome
//        }
//        
//        func makeTestSubject() -> BreederTestSubject {
//            if let g = genome {
//                return TSNumberGuesser.makeTestSubject(with: g)
//            }
//            
//            // Random genome, as of 19Nov2018
//            return TSNumberGuesser.makeTestSubject()
//        }
//    }
//    
//    func testGeneration() {
//        let generation = Generation()
//        
//        // Create a generation with a winner, make sure the
//        // Generation detects it and gives us back the winner.
//        for whichSubject in 0..<10 {
////            let testSubject =
////                TestSubjectForTesting.makeTestSubject(from: <#T##LayerOwnerProtocol#>, genome: Genome())
//            
//            generation.addTestSubject(subject: testSubject)
//            
//            if whichSubject == 5 { testSubject.fitnessScore = 0; continue }
//            testSubject.fitnessScore = Double(testSubject.myFishNumber)
//        }
//        
//        var bestTestSubject = generation.submitToTest(for: [1.0, 1.0, 1.0, 1.0])
//        
//        // First round of test subjects will have a winner
//        precondition(bestTestSubject != nil)
//        
//        // Create a generation with no survivors, make sure we
//        // get back nil
//        for _ in 0..<10 {
//            let testSubject = TestSubjectForTesting()
//            testSubject.failAllTests = true
//            generation.addTestSubject(subject: testSubject)
//        }
//        
//        bestTestSubject = generation.submitToTest(for: [1.0, 1.0, 1.0, 1.0])
//        
//        precondition(bestTestSubject == nil)
//    }
//}
//#endif
//
//class TSMockTestSubject: BreederTestSubject {
//    class TSF: BreederTestSubjectFactory {
//        let genome: Genome?
//        
//        init() {
//            Translators.numberOfSenses = 1
//            Translators.numberOfMotorNeurons = 1
//            genome = nil
//        }
//        
//        init(genome: Genome) { self.genome = genome }
//        
//        func makeTestSubject() -> BreederTestSubject {
//            if let g = genome {
//                return TSMockTestSubject(genome: g, brain: nil)
//            }
//            
//            // Random genome, as of 19Nov2018
//            return TSMockTestSubject.makeTestSubject()
//        }
//    }
//    
//    private init(genome: Genome?, brain: LayerOwnerProtocol?) {
//        if Breeder.howManyTestSubjectsPerGeneration != Breeder.howManyGenerations {
//            fatalError("Because the pass-through test subject is such a primitive pos, these two must be equal")
//        }
//        
//        if let g = genome {
//            super.init(genome: g)
//            
//            if let b = brain { self.brain = b }
//            else { self.brain = TSMockTestSubject.makeBrain(from: g) }
//            
//            return
//        }
//        
//        super.init()
//        self.genome = RandomnessGenerator.generateRandomGenome()
//        self.brain = TSMockTestSubject.makeBrain(from: self.genome!)
//    }
//    
//    required init() {
//        fatalError("init() has not been implemented")
//    }
//    
//    required init(genome: Genome) {
//        fatalError("init(genome:) has not been implemented")
//    }
//    
//    override class func makeBrain(from genome: Genome) -> LayerOwnerProtocol {
//        return BrainMockTestSubject()
//    }
//    
//    override class func makeTestSubject(with genome: Genome?) -> BreederTestSubject{
//        selectionControls.theFishNumber += 1
//        return TSMockTestSubject(genome: genome, brain: nil)
//    }
//    
//    override class func makeTestSubject() -> BreederTestSubject {
//        return TSMockTestSubject(genome: nil, brain: nil)
//    }
//    
//    class func setBreederTestSubjectFactory() {
//        _ = Breeder.bb.setTestSubjectFactory(TSF())
//    }
//    
//    override func spawn() -> BreederTestSubject? {
//        return TSMockTestSubject.makeTestSubject()
//    }
//}
//
//class FTMockFitnessTester: BreederFitnessTester {
//    var counter = 0
//    var bestScore = Double(Breeder.howManyGenerations + 2)
//    
//    func administerTest(to testSubject: BreederTestSubject) -> (Double, String)? {
//        counter += 1
//        if counter > Breeder.howManyTestSubjectsPerGeneration {
//            counter = 0
//            bestScore -= 1
//            return getFitnessScore(for: [bestScore])
//        }
//        
//        return getFitnessScore(for: [Double(Breeder.howManyGenerations + 1)])
//    }
//    
//    internal func getFitnessScore(for outputs: [Double]) -> (Double, String) {
//        return (outputs[0], "Fitness score for individual = \(outputs[0])")
//    }
//}
//
//class BrainMockTestSubject: LayerOwnerProtocol {
//    
//    var layers = [Translators.Layer]()
//    
//    func addActivator(_ active: Bool) { }
//    func setBias(_ value: ValueDoublet) { }
//    func setBias(_ baseline: Double, _ value: Double) { }
//    func addWeight(_ value: ValueDoublet) { }
//    func addWeight(_ baseline: Double, _ value: Double) { }
//    func connectLayers() { }
//    func closeLayer() { }
//    func closeNeuron() { }
//    func endOfStrand() { }
//    func newLayer() { }
//    func newNeuron() { }
//    func setInputs(_ inputs: [Int]) { }
//    func setThreshold(_ value: ValueDoublet) { }
//    func setThreshold(_ baseline: Double, _ value: Double) { }
//    func show(tabs: String, override: Bool) { }
//    func stimulate(inputs: [Double]) -> [Double]? { return [1] }
//    func generateRandomSensoryInput() -> [Double] { return [1] }
//}
//
