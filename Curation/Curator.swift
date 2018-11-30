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

struct SelectionControls {
    var howManySenses = 5
    var howManyMotorNeurons = "Zoe Bishop".count
    var howManyGenerations = 30000
    var howManyGenes = 200
    var howManySubjectsPerGeneration = 200
    var theFishNumber = 0
    var dudlinessThreshold = 5
    var stackNoobsLimit = 5
}

var selectionControls = SelectionControls()

class Curator {
    typealias TSSet = Set<TSTestSubject>

    enum EQTest { case ge, gt }

    var aboriginal: TSTestSubject!
    var bestTestSubject: TSTestSubject!
    var remainingGenerations = 0
    let selector: Selector
    let stack = Stack()
    var testSubjects = [TSTestSubject]()
    let tsFactory: TestSubjectFactory

    init(tsFactory: TestSubjectFactory) {
        self.tsFactory = tsFactory
        self.selector = Selector(tsFactory: tsFactory)
        
        // This has to happen after the Selector init,
        // because the Selector calls into the tsFactory
        // which inits the fitness tester, which sets the
        // controls. Seems rather ugly. Come back to it.
        self.remainingGenerations = selectionControls.howManyGenerations
    }

    func select() -> TSTestSubject? {
        guard let a = Curator.makePromisingAboriginal(using: tsFactory)
            else { return nil }

        stack.postInit(aboriginal: a)
        
        self.aboriginal = a
        self.bestTestSubject = a
        selector.scoreAboriginal(a)
        print("Aboriginal score = \(a.fitnessScore!)")
        
        while remainingGenerations > 0 && a.fitnessScore! != 0 {
            defer { remainingGenerations -= 1 }

            let (eqTest, newTestSubject) = stack.getSelectionParameters()

            if newTestSubject.fitnessScore! != self.bestTestSubject.fitnessScore! {
                print("New record by \(newTestSubject.fishNumber): \((newTestSubject.fitnessScore!))")
            }// else { print(".\(eqTest)", terminator: "") }
            
            self.bestTestSubject = newTestSubject
            
            guard let newPotentials = selector.select(eqTest: eqTest, against: self.bestTestSubject)
                else { fatalError() }
            
            stack.stack(newPotentials)
            
            if self.bestTestSubject.fitnessScore! == 0.0 { break }
        }
        
        print("Best score \(self.bestTestSubject.fitnessScore!) from \(self.bestTestSubject.fishNumber), genome \(bestTestSubject.genome)")
        return self.bestTestSubject
    }
}

private extension Curator {
    static func makeOneLayer(_ protoGenome_: Genome, ctNeurons: Int) -> Genome {
        var protoGenome = protoGenome_ + "L_"
        
        for portNumber in 0..<ctNeurons {
            protoGenome += "N_"
            for _ in 0..<portNumber { protoGenome += "A(false)_" }

#if PROMISING_GENOME_FOR_ZOE
            let randomBias = Double.random(in: -1...1).sTruncate()
            let randomWeight = Double.random(in: -1...1).sTruncate()
            protoGenome += "A(true)_F(linear)_W(b[\(randomWeight)]v[\(randomWeight)])_B(b[\(randomBias)]v[\(randomBias)])_"
#else
            protoGenome += "A(true)_F(linear)_W(b[\(1)]v[\(1)])_B(b[\(0)]v[\(0)])_"
#endif
        }
        
        return protoGenome
    }
    
    static func makePromisingAboriginal(using factory: TestSubjectFactory) -> TSTestSubject? {
        var dag = Genome()
        for _ in 0..<3 { dag = makeOneLayer(dag, ctNeurons: 5) }
        dag = makeOneLayer(dag, ctNeurons: selectionControls.howManyMotorNeurons)
        
        return factory.makeTestSubject(parentGenome: dag, mutate: false)
    }
}

extension Array {
    // It's easier for me to think about the breeders as a stack
    mutating func pop() -> Element { return self.removeFirst() }
    mutating func push(_ e: Element) { self.insert(e, at: 0) }
    mutating func popBack() { _ = self.removeLast() }
}
