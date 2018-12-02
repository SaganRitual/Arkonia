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
    var howManyGenerations = 25
    var howManyGenes = 200
    var howManySubjectsPerGeneration = 200
    var theFishNumber = 0
    var dudlinessThreshold = 5
    var stackNoobsLimit = 5
}

var selectionControls = SelectionControls()

enum NotificationType: String {
    case selectComplete = "selectComplete", select = "select", setSelectionParameters = "setSelectionParameters"
}

class Curator {
    var aboriginal: TSTestSubject!
    var bestTestSubject: TSTestSubject!
    let notificationCenter = NotificationCenter.default
    var remainingGenerations = 0
    let selector: Selector
    let semaphore = DispatchSemaphore(value: 0)
    let stack = Stack()
    var testSubjects = [TSTestSubject]()
    let tsFactory: TestSubjectFactory

    init(tsFactory: TestSubjectFactory) {
        self.tsFactory = tsFactory
        self.selector = Selector(tsFactory: tsFactory, semaphore: semaphore)
        
        // This has to happen after the Selector init,
        // because the Selector calls into the tsFactory
        // which inits the fitness tester, which sets the
        // controls. Seems rather ugly. Come back to it.
        self.remainingGenerations = selectionControls.howManyGenerations
        
        let n = Foundation.Notification.Name.selectComplete
        let s = #selector(selectComplete)
        notificationCenter.addObserver(self, selector: s, name: n, object: nil)
        
        self.selector.startThread()
    }
    
    deinit { notificationCenter.removeObserver(self);  }
    
    func getBestTestSubject() -> TSTestSubject? {
        return self.bestTestSubject
    }

    func select() -> TSTestSubject? {
        let dag = "L_N_A(true)_F(linear)_W(b[1]v[1])_B(b[0]v[0])_N_A(false)_A(true)_F(linear)_W(b[1]v[1])_B(b[0]v[0])_N_A(false)_A(false)_A(true)_F(linear)_W(b[1]v[1])_B(b[0]v[0])_A(true)_F(linear)_W(b[1]v[1])_B(b[0]v[0])_"
        guard let a = tsFactory.makeTestSubject(parentGenome: dag, mutate: false)
            else { return nil }

        stack.postInit(aboriginal: a)
        
        self.aboriginal = a
        self.bestTestSubject = a
        selector.scoreAboriginal(a)
        print("Aboriginal score = \(a.fitnessScore!)")
        
        var firstPass = true
        
        while remainingGenerations > 0 {
            defer { remainingGenerations -= 1 }
            
            // We skip waiting on the first pass because the thread is
            // currently waiting for it; we don't want to block. After this
            // pass, the Curator and the thread will take turns by passing
            // the semaphore back and forth.
            if !firstPass { semaphore.wait() }

            let newTestSubject = stack.getSelectionParameters()

            if newTestSubject.fitnessScore! != self.bestTestSubject.fitnessScore! {
                print("New record by \(newTestSubject.fishNumber): \(newTestSubject.fitnessScore!)")
            } else {
//                print("\(newTestSubject.fishNumber): \((newTestSubject.fitnessScore!)) -- stack \(stack.count) elements deep")
                
            }
            
            self.bestTestSubject = newTestSubject
            let n1 = Foundation.Notification.Name.setSelectionParameters
            let q1 = [NotificationType.select : newTestSubject]
            let p1 = Foundation.Notification(name: n1, object: nil, userInfo: q1)

            let n2 = Foundation.Notification.Name.select
            let p2 = Foundation.Notification(name: n2, object: nil, userInfo: nil)

            notificationCenter.post(p1)
            notificationCenter.post(p2)

            semaphore.signal()  // Everything is in place; start the selector running

            firstPass = false
            if self.bestTestSubject.fitnessScore! == 0.0 { break }
        }
        
        selector.cancel()
        print("Best score \(self.bestTestSubject.fitnessScore!) from \(self.bestTestSubject.fishNumber), genome \(bestTestSubject.genome)")
        return self.bestTestSubject
    }
    
    @objc func selectComplete(_ notification: Notification) {
        guard let u = notification.userInfo,
            let p = u[NotificationType.selectComplete] as? TSArray
            else {
                if self.selector.isCanceled { return }
                preconditionFailure()
            }
        
        stack.stack(p)
        print("(\(stack.count) items on stack)")
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
