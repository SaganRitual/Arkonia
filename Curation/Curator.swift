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
    var dudlinessThreshold = 1
    var stackTieScoresLimit = 5
    var keepersPerGenerationLimit = 3
}

var selectionControls = SelectionControls()

class Statics {
    static let s = Statics()
    
    private let sensesInterface_: Genome!
    private let outputsInterface_: Genome!
    private let aboriginalGenome: Genome

    public let sensesInterface: GenomeSlice
    public let outputsInterface: GenomeSlice
    public let recognizedTokens: String = "ABFHLNRW"
    
    init() {
        sensesInterface_ = Statics.makeSensesInterface()
        outputsInterface_ = Statics.makeOutputsInterface()
        sensesInterface = sensesInterface_[...]
        outputsInterface = outputsInterface_[...]
        aboriginalGenome = Statics.makeAboriginalGenome(3)
    }

    var act_s: GenomeSlice { return token("A") } // Activator -- Bool
    var bis_s: GenomeSlice { return token("B") } // Bias -- Stubble
    var fun_s: GenomeSlice { return token("F") } // Function -- string
    var hox_s: GenomeSlice { return token("H") } // Hox gene -- haven't worked out the type yet
    var lay_s: GenomeSlice { return token("L") } // Layer
    var neu_s: GenomeSlice { return token("N") } // Neuron
    var ifm_s: GenomeSlice { return token("R") } // Interface marker
    var wgt_s: GenomeSlice { return token("W") } // Weight -- Stubble

    public func token(_ character: Character) -> GenomeSlice {
        guard let start = recognizedTokens.firstIndex(of: character) else {
            preconditionFailure()
        }
        
        return recognizedTokens[start...start]
    }
    
    public func getAboriginalGenome() -> GenomeSlice {
        return Statics.s.aboriginalGenome[...]
    }
    
    private static func makeAboriginalGenome(_ hmLayers: Int) -> Genome {
        var dag = Genome()
        for _ in 0..<hmLayers { dag = makeOneLayer(dag, ctNeurons: 5) }
        return dag
    }

    private static func makeSensesInterface() -> Genome {
        var g = Genome(); g += layb
        
        for portNumber in 0..<selectionControls.howManySenses {
            g += neub
            for _ in 0..<portNumber { g += "A(false)_" }
            
            g += "A(true)_W(b[1.0]v[1.0])_B(b[0.0]v[0.0])_"
        }
        
        g += ifmb; return g
    }

    public static func makePromisingAboriginal(factory: TestSubjectFactory) -> TSTestSubject? {
        let p = Statics.s.getAboriginalGenome()
        return factory.makeTestSubject(parentGenome: p, mutate: false)
    }
    
    private static func makeOneLayer(_ protoGenome_: Genome, ctNeurons: Int) -> Genome {
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

    private static func makeOutputsInterface() -> Genome {
        var g = Genome(); g += ifmb + layb
        for portNumber in 0..<selectionControls.howManyMotorNeurons {
            g += neub
            for _ in 0..<portNumber { g += "A(false)_" }
            g += "A(true)_W(b[1.0]v[1.0])_B(b[0.0]v[0.0])_"
        }
        return g
    }
}

enum NotificationType: String {
    case selectComplete, select, setSelectionParameters
}

enum CuratorStatus { case running, finished }

enum CandidateFilter: String { case be = "BE", bt = "BT" }

class Curator {
    var aboriginal: TSTestSubject!
    var atLeastOneTSHasSurvived = false
    var bestTestSubject: TSTestSubject!
    let notificationCenter = NotificationCenter.default
    var remainingGenerations = 0
    let selector: Selector
    let semaphore = DispatchSemaphore(value: 0)
    let stack = Stack()
    let tsFactory: TestSubjectFactory
    private var observerHandle: NSObjectProtocol?
    public var status = CuratorStatus.running

    init(tsFactory: TestSubjectFactory) {
        
        self.tsFactory = tsFactory
        self.selector = Selector(tsFactory: tsFactory, semaphore: semaphore)

        // This has to happen after the Selector init,
        // because the Selector calls into the tsFactory
        // which inits the fitness tester, which sets the
        // controls. Seems rather ugly. Come back to it.
        self.remainingGenerations = selectionControls.howManyGenerations
        
        let n = Foundation.Notification.Name.selectComplete
        observerHandle = notificationCenter.addObserver(forName: n, object: selector, queue: nil) {
            [unowned self] notification in self.selectComplete(notification)
        }

        self.selector.startThread()
    }

    deinit {
        if let oh = observerHandle {
            notificationCenter.removeObserver(oh); print("Curator deinit")
        }
    }

    func getBestTestSubject() -> TSTestSubject? {
        return bestTestSubject
    }

    func select() -> TSTestSubject? {
//         This genome produces the number 6. Saving it because although
//         it's interesting, it's also easy to understand from reading the
//         genome or looking at its display representation.
//        let dag = "L_N_A(true)_F(linear)_W(b[1]v[1])_B(b[0]v[0])_N_A(false)_A(true)_F(linear)_W(b[1]v[1])_B(b[0]v[0])_N_A(false)_A(false)_A(true)_F(linear)_W(b[1]v[1])_B(b[0]v[0])_A(true)_F(linear)_W(b[1]v[1])_B(b[0]v[0])_"
//        guard let a = tsFactory.makeTestSubject(parent: aboriginal, mutate: false)
//            else { return nil }

//         This one is much longer, but it also produces exactly 6.
//         let dag = "L_N_A(true)_F(linear)_W(b[1]v[1])_B(b[0]v[0])_N_A(false)_A(true)_F(linear)_W(b[1]v[1])_B(b[0]v[0])_N_A(false)_A(false)_A(true)_F(linear)_W(b[1]v[1])_B(b[0]v[0])_N_A(false)_A(false)_A(false)_A(true)_F(linear)_W(b[1]v[1])_A(false)_A(false)_A(true)_F(linear)_W(b[1]v[1])_B(b[0]v[0])_N_A(false)_A(false)_A(false)_A(true)_F(linear)_W(b[1]v[1])_B(b[0]v[0])_N_A(false)_A(false)_A(false)_A(false)_A(true)_F(linear)_W(b[1]v[1])_B(b[0]v[0])_"

        guard let a = Statics.makePromisingAboriginal(factory: tsFactory)
            else { return nil }

        stack.postInit(aboriginal: a)

        self.aboriginal = a
        self.bestTestSubject = a
        selector.scoreAboriginal(a)
        self.atLeastOneTSHasSurvived = true
        print("Aboriginal score = \(a.fitnessScore!)")

        var firstPass = true

        while remainingGenerations > 0 {
            defer { remainingGenerations -= 1 }

            // We skip waiting on the first pass because the thread is
            // currently waiting for it; we don't want to block. After this
            // pass, the Curator and the thread will take turns by passing
            // the semaphore back and forth.
            if !firstPass { semaphore.wait() }

            let (newTestSubject, candidateFilterType) = stack.getSelectionParameters()

            if newTestSubject.fitnessScore! != self.bestTestSubject.fitnessScore! {
                print("New record by \(newTestSubject.fishNumber): \(newTestSubject.fitnessScore!)")
            }

            self.bestTestSubject = newTestSubject
            let n1 = Foundation.Notification.Name.setSelectionParameters
            let q1 = [NotificationType.select : newTestSubject, "candidateFilter" : candidateFilterType] as [AnyHashable : Any]
            let p1 = Foundation.Notification(name: n1, object: nil, userInfo: q1)

            let n2 = Foundation.Notification.Name.select
            let p2 = Foundation.Notification(name: n2, object: nil, userInfo: nil)

            notificationCenter.post(p1)
            notificationCenter.post(p2)

            semaphore.signal()  // Everything is in place; start the selector running

            firstPass = false
            if self.bestTestSubject.fitnessScore! == 0.0 { break }
        }

        // We're moving, of course, so the selector will be
        // waiting for the semaphore

        semaphore.signal()
        selector.cancel()
        status = .finished
        print("Best score \(self.bestTestSubject.fitnessScore!) from \(self.bestTestSubject.fishNumber), genome \(bestTestSubject.genome)")
        return self.bestTestSubject
    }

    @objc func selectComplete(_ notification: Notification) {
        guard let u = notification.userInfo,
            let p = u[NotificationType.selectComplete] as? TSArray
            else {
                if !self.selector.isCanceled { return }
                preconditionFailure()
            }

        stack.stack(p)
//        print("(\(stack.count) items on stack)")

        self.atLeastOneTSHasSurvived = true
    }
}

extension Array {
    // It's easier for me to think about the breeders as a stack
    mutating func pop() -> Element { return self.removeFirst() }
    mutating func push(_ e: Element) { self.insert(e, at: 0) }
    mutating func popBack() -> Element { return self.removeLast() }
    mutating func pushFront(_ e: Element) { push(e) }
}
