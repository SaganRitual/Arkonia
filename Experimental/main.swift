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

//class TestBreeder {
//    var shouldKeepRunning = true
//
//    var currentGenerationNumber = 0
//    func select() -> Double {
//        let bestFitnessScore = Breeder.bb.breedAndSelect()
//
//        currentGenerationNumber += 1
//        if currentGenerationNumber >= Breeder.howManyGenerations || bestFitnessScore == 0 {
//            self.shouldKeepRunning = false
//        }
//
//        return bestFitnessScore
//    }
//}
//
//let numberOfSenses = 2
//let numberOfMotorNeurons = 2
//let numberOfGenerations = 100
//let numberOfTestSubjectsPerGeneration = 100
//
//var newGenome = Genome()
//
//newGenome += "L."
//for _ in 0..<numberOfSenses {
//    newGenome += "N.A(true).W(1).b(0).t(5555)."
//}
//
//let testSubjectFactory =
//    TSNumberGuesser.TSF(genome: newGenome, numberOfSenses: numberOfSenses, numberOfMotorNeurons: numberOfMotorNeurons,
//                        numberOfGenerations: numberOfGenerations, numberOfTestSubjectsPerGeneration: numberOfTestSubjectsPerGeneration)
//
//_ = Breeder.bb.setTestSubjectFactory(testSubjectFactory)
//Breeder.bb.setFitnessTester(FTNumberGuesser())
//
//let tb = TestBreeder()
//
//let v = RepeatingTimer(timeInterval: 0.1)
//var bestFitnessScore = 0.0
//v.eventHandler = {
//    bestFitnessScore = tb.select()
//}
//v.resume()
//while tb.shouldKeepRunning {  }
//print("Best score \(bestFitnessScore)", Breeder.bb.getBestGenome())

let z = ZoeTestSubjectSetup()
z.run()
