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

func oneSignalPassThroughRandomBrain() {
    let brain = Breeder.makeRandomBrain()
    print(brain.stimulate(inputs: brain.generateRandomSensoryInput()))
}

func controlledConditionsTest() {
    let testGenomes = [
        "L.N.A(true)."//.W(1).b(2).t(1)", "L.N.A(true).W(1).b(1).t(2)",
//        "L.N.A(true).W(1).b(-4).t(2)", "L.N.A(true).W(1).W(1).b(-4).t(2)",
//        "L.N.A(true).A(true).W(1).b(1).t(2)", "L.N.A(true).A(true).W(1).W(1).b(1).t(2)",
//        "L.N.A(true).W(1).A(true).W(1).b(1).t(2)", "L.N.b(1).t(2).A(true).W(1).A(true).W(1)"*/

//        "L.N.A(true).W(1).b(1).t(100).N.A(true).W(2).b(2).t(100).",
//        "L.N.A(true).W(1).b(1).b(37).t(12).t(1107).N.A(true).W(2).A(false).W(3).A(true).W(4).A(false).W(5).A(true).W(6).A(true).b(2).t(100).",
//        "L.N.A(true).W(1).b(1).b(37).t(12).t(1107).N.A(true).W(2).A(false).W(3).N.A(true).W(4).A(false).W(5).A(true).W(6).A(true).b(2).t(100)."
    ]

    for testGenome in testGenomes {
        let allOnes = testGenome

        let decoder = Decoder()
        decoder.setInput(to: allOnes).decode()
        let brain = Translators.t.getBrain()

        let oneSense = [1.0]
        let output = brain.stimulate(inputs: oneSense)
        print(output)
    }
}

func testMutator() {
    let testInput = "L.N.A(true).W(1).b(1).b(37).t(12).t(1107).N.A(true).W(2).I(42).A(false).W(3).N.A(true).W(4).A(false).W(5).A(true).W(6).A(true).b(2).t(100)."

//    let tegex = "L\\.|N\\.|[AB]\\((true|false)\\)\\.|[bDtW]\\((\\d*\\.?\\d*)\\)\\.|I\\((\\d+)\\)"
//    let regex = "L\\.|N\\.|[AB]\\((true|false)\\)\\.|[DtW]\\(([0-9]*\\.?\\d*)\\)\\.|[Ib]\\((\\d+)\\)"
//    let uegex = "[LN]\\.||[Ib]\\((\\[0-9\\]+\\.?)\\)\\.|[AB]\\(((?:true)|(?:false))\\)\\.|[DWt]\\(([0-9]*\\.?[0-9]*)\\)\\."

/* this one works, 16Nov18 */
    let _/*vegex*/ = "[LN]\\.|([ABDIWbt])\\(([^\\(]*)\\)\\."

//    let something = testInput.searchRegex(regex: vegex)
//    print(something)
    
    _ = Mutator.m.setInputGenome(testInput).mutate()
    print("mutated:  ", terminator: "")
    let newGenome = Mutator.m.convertToGenome()
    print("before", testInput)
    print("after", newGenome)
}

func chopTail(of string: String, howManyToKeep: Int) -> GenomeSlice {
    let howManyToCut = string.count - howManyToKeep
    return string.dropLast(howManyToCut)
}

func testBreeder() {
    let howManyGenes = 50
    
    let newGenome = Breeder.generateRandomGenome(howManyGenes: howManyGenes)
    
    Breeder.bb.setProgenitor(newGenome)
    Breeder.bb.breedOneGeneration(10, from: newGenome)

    let selection = Breeder.bb.selectFromCurrentGeneration()

    for (ss, genome) in zip(0..., selection) {
        print("Genome \(ss): ", genome)
    }

//    let characterLimit = 50
//    let howManyToKeep = selection.count > characterLimit ? characterLimit : selection.count
//    print("winner: (\(selection.count))", selection.first!)
}

//oneSignalPassThroughRandomBrain()
controlledConditionsTest()
//testMutator()

//print("testing breeder")
//testBreeder()

//func show() {
//    if Utilities.thereBeNoShowing { return }
//    testTranslators.brain.show(tabs: "", override: true)
//
//}
//
//func translatorFunction() {
//    var testTranslators = Translators()
//    testTranslators.newBrain()
//
//    for _ in 0..<2 {
//        testTranslators.newLayer()
//
//        for _ in 0..<5{
//            testTranslators.newNeuron()
//
//            testTranslators.setThreshold(Double.infinity)
//            testTranslators.setBias(0)
//
//            for _ in 0..<1 {
//                testTranslators.addWeight(1)
//            }
//            testTranslators.closeNeuron()
//        }
//
//        testTranslators.closeLayer()
//    }
//
//    //testTranslators.closeBrain()
//    testTranslators.endOfStrand()
//    Utilities.thereBeNoShowing = false
//    show()
//
//    let brain = testTranslators.getBrain()
//    let outputs = brain.stimulate(inputs: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1])
//    print(outputs)
//}
