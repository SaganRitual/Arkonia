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
    let rsi = brain.generateRandomSensoryInput()
    print(rsi)
    //    if let results = rsi { print(results) }
    //    else { print("Brain died during testing" }
}

func controlledConditionsTest() {
    for testGenome in testGenomes {
        let allOnes = testGenome
        
        let decoder = Decoder()
        decoder.setInput(to: allOnes).decode()
        let brain = Translators.t.getBrain()
        
        let oneSense = [1.0]
        let output = brain.stimulate(inputs: oneSense)
        if let t = output { print("Success, or something: \(t)") }
        else { print("Brain died during testing") }
    }
}


func testMutator() {
    let testInput = "L.N.A(true).W(b[1]v[1]).B(b[1]v[1]).B(b[37]v[37]).T(b[12]v[12]).T(b[1107]v[1107]).N.A(true).W(b[2]v[2]).A(false).W(b[3]v[3]).N.A(true).W(b[4]v[4]).A(false).W(b[5]v[5]).A(true).W(b[6]v[6]).A(true).B(b[2]v[2]).T(b[100]v[100])."
    
    let wrapped = Utilities.applyInterfaces(to: testInput)
    _ = Mutator.m.setInputGenome(String(wrapped)).mutate()

    let newGenome = Mutator.m.convertToGenome()
    print("after")
    print(newGenome)
}

//for _ in 0..<50 {
//    testMutator()
//}

func chopTail(of string: String, howManyToKeep: Int) -> GenomeSlice {
    let howManyToCut = string.count - howManyToKeep
    return string.dropLast(howManyToCut)
}

func testBreeder() {
    let howManyGenes = 50
    
    let newGenome = Breeder.generateRandomGenome(howManyGenes: howManyGenes)
    
    Breeder.bb.setProgenitor(newGenome)
    Breeder.bb.breedOneGeneration(10, from: newGenome)
    
    guard let selection = Breeder.bb.selectFromCurrentGeneration() else {
        print("Brain died during stimulation")
        return
    }
    
    for (ss, genome) in zip(0..., selection) {
        print("Genome \(ss): ", genome)
    }
}

//    let characterLimit = 50
//    let howManyToKeep = selection.count > characterLimit ? characterLimit : selection.count
//    print("winner: (\(selection.count))", selection.first!)
//    }

func lotsOTests() {
    
    oneSignalPassThroughRandomBrain()
    controlledConditionsTest()
    testMutator()
    
    print("testing breeder")
    testBreeder()
    
    let testTranslators = Translators()
    testTranslators.newBrain()
    
    func show() {
        if Utilities.thereBeNoShowing { return }
        testTranslators.brain.show(tabs: "")
        
    }
    
    for _ in 0..<2 {
        testTranslators.newLayer()
        
        for _ in 0..<5{
            testTranslators.newNeuron()
            
            testTranslators.setThreshold(Double.infinity)
            testTranslators.setBias(0)
            
            for _ in 0..<1 {
                testTranslators.addWeighT(b[1]v[1])
            }
            testTranslators.closeNeuron()
        }
        
        testTranslators.closeLayer()
    }
}

func someOtherTests() {
    //testTranslators.closeBrain()
    testTranslators.endOfStrand()
    Utilities.thereBeNoShowing = false
    show()
    
    let brain = testTranslators.getBrain()
    let outputs = brain.stimulate(inputs: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1])
    if let oop = outputs { print(oop) }  else { print("wtf") }
}
