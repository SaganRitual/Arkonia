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

typealias Tenome = Array<Tene>
typealias Tegment = ArraySlice<Tene>

class Tene {
    // The components are the results of a regex. For each tene,
    // we get the submatches from this array, which represent
    // the token and the value, respectively.
    let components = Array<String>()
    let token: Character
    var value: String
    
    var description: String { get {
        if token == L || token == N { return "MarkerGene: \(token)" }
        else { return "\(token) gene: \(value)" }
    }}
    
    init(_ token: String, value: String) { self.token = Character(token); self.value = value }
    func mutate() {
        if self.value.first! == "t" || self.value.first! == "f" {
            self.value = String(Bool.random()); return
        }

        self.value = String(Mutator.m.getWeightedRandomLogThing(from: Double(self.value)!).dTruncate())
    }
}

class Mutator {
    public static var m = Mutator()
    
    var e = Translators.t
    var inputGenome: Genome?
    var workingTenome = Tenome()
    
    func setInputGenome(_ inputGenome: Genome) -> Mutator {
        self.inputGenome = Utilities.stripInterfaces(from: inputGenome)
        let rawComponentSets = Mutator.getRawComponentSets(for: self.inputGenome!)
        workingTenome = Tenome()

        for rawComponentSet in rawComponentSets {
            let literalMatch = String(rawComponentSet[0])
            let token = (rawComponentSet.count > 1) ? Character(rawComponentSet[1]) : literalMatch.first!
            let value = (rawComponentSet.count > 2) ? rawComponentSet[2] : "<nil>"

            workingTenome.append(Tene(String(token), value: value))
        }
        
        return Mutator.m
    }
    
    enum MutationType: Int {
        case insertRandom, insertSequence, deleteRandom, deleteSequence,
        snipAndMoveSequence, snipAndCopySequence, snipAndMoveReversedSequence,
        snipAndCopyReversedSequence, mutateGenes
        
        case endIndex = 9   // Acts as an npos like in C++
    }
    
    public func convertToGenome() -> Genome {
        var genome = Genome()
        
        for tene in workingTenome {
            if tene.token == L || tene.token == N {
                genome += String(tene.token) + "."
            } else {
                genome += String(tene.token) + "(" + tene.value + ")."
            }
        }
        
        return genome
    }
    
    private func copySegment() -> Tegment {
        let (leftCut, rightCut) = getRandomCuts(segmentLength: workingTenome.count)
        return workingTenome[leftCut..<rightCut]
    }
    
    private func deleteGenes() {
        let howManyChances = getWeightedRandomLogThing(from: 10)
        for _ in 0..<Int.random(in: 0..<howManyChances) {
            let ix = Int.random(in: 0..<workingTenome.count)
            workingTenome.remove(at: ix)
            if workingTenome.isEmpty { break }
        }
    }
    
    private func deleteSequence() {
        let (leftCut, rightCut) = getRandomCuts(segmentLength: workingTenome.count)
        workingTenome.removeSubrange(leftCut..<rightCut)
    }
    
    private func getRandomCuts(segmentLength: Int) -> (Int, Int) {
        let leftCut = Int.random(in: 0..<segmentLength)
        let rightCut = getWeightedRandomLogThing(from: leftCut, min: 0.0, max: Double(segmentLength))
        return (leftCut, rightCut)
    }
    
    private func getRandomSnipRange() -> (Int, Int) {
        if workingTenome.isEmpty { return (0, 0) }
        
        let (leftCut, rightCut) = getRandomCuts(segmentLength: workingTenome.count)
        return (leftCut, rightCut)
    }
    
    // Big changes happen very rarely, little ones more often
    func getWeightedRandomLogThing(from startingValue: Int, min min_: Double? = nil, max max_: Double? = nil) -> Int {
        let min = (min_ == nil) ? -1e10 : min_!
        let max = (max_ == nil) ? 1e10 : max_!
        
        let randomPercentage = Double.random(in: min..<max)
        if randomPercentage == 0 { return 1 }
        
        let d = ((0.001 / randomPercentage) * Double(startingValue)).rounded(.towardZero)
        
        return startingValue + Int(d)
    }

    fileprivate func getWeightedRandomLogThing(from startingValue: Double, min min_: Double? = nil, max max_: Double? = nil) -> Double {
        let min = (min_ == nil) ? -1e10 : min_!
        let max = (max_ == nil) ? 1e10 : max_!

        let randomPercentage = Double.random(in: min..<max)
        if randomPercentage == 0 { return 1 }

        let i = (0.0001 / randomPercentage) * startingValue
        return startingValue + i
    }
    
    private func getWeightedRandomMutationType() -> MutationType  {
        let weightMap: [MutationType : Int] = [
            .deleteRandom : 1, .deleteSequence : 1, .insertRandom : 1, .insertSequence : 1,
            .mutateGenes : 100, .snipAndMoveSequence : 1, .snipAndCopySequence : 1,
            .snipAndMoveReversedSequence : 1, .snipAndCopyReversedSequence : 1
        ]
        
        let weightRange = weightMap.reduce(0, { return $0 + $1.value })
        let randomValue = Int.random(in: 0..<weightRange)
        
        var runningTotal = 0
        for (key, value) in weightMap {
            runningTotal += value
            if runningTotal > randomValue { return key }
        }
        
        fatalError()
    }

    private func insertGenes() {
        for _ in 0...Int.random(in: 0..<10) {
            let insertPoint = Int.random(in: 0...workingTenome.count)    // Note closed range
            let newTene = Mutator.generateRandomTene()
            workingTenome.insert(newTene, at: insertPoint)
        }
    }
    
    private func insertSequence() {
        var snippet = Tenome()
        
        for _ in 0..<Int.random(in: 1...10) {
            let newTene = Mutator.generateRandomTene()
            snippet.append(newTene)
        }
        
        // Notice: closed range, including one past the end. Doc says
        // you must use a valid index, but then says the endIndex value
        // is legal too. I guess that's how you can insert anywhere into
        // the workingTenome. The "at" parameter should be called "before". We're
        // inserting before "insertPoint".
        let insertPoint = Int.random(in: 0...workingTenome.count)
        workingTenome.insert(contentsOf: snippet, at: insertPoint)
    }

    func mutate(mutationType: MutationType? = nil) -> Tenome {
        let m = getWeightedRandomMutationType()
        var outputTegment = Tenome(workingTenome)

        switch m {
        case .deleteRandom:          /* print("(1)"); */ deleteGenes()
        case .deleteSequence:        /* print("(2)"); */ deleteSequence()
            
        case .insertRandom:         /* print("(3)"); */ insertGenes()
        case .insertSequence:       /* print("(4)"); */ insertSequence()
            
        case .mutateGenes:          /* print("(five)"); */ mutateGenes()
            
        case .snipAndMoveSequence:  /* print("(6)"); */ outputTegment = snipAndMoveSequence()
        case .snipAndCopySequence:  /* print("(7)"); */ outputTegment = snipAndCopySequence()
            
        case .snipAndMoveReversedSequence: /* print("(8)"); */ outputTegment = snipAndMoveReversedSequence()
        case .snipAndCopyReversedSequence: /* print("(9)"); */ outputTegment = snipAndCopyReversedSequence()
            
        case .endIndex: fatalError("😭😭😭😭😭 Swift is broken 😭😭😭😭😭")
        }
        
        return outputTegment
    }
    
    private func mutateGenes() {
        if workingTenome.isEmpty { return }
        for _ in 0...Int.random(in: 0..<10) {
            let ix = Int.random(in: 0..<workingTenome.count)
            if workingTenome[ix].value.first != "<" {   // "<nil>"
                workingTenome[ix].mutate()
            }
        }
    }
    
    func show(_ tenome: Tenome) {
        var separator = ""
        for tene in tenome {
            print(separator + tene.description, terminator: "")
            separator = ", "
        }
        print()
    }

    private func snipAndCopySequence() -> Tenome {
        if workingTenome.isEmpty { return workingTenome }
        
        let (leftCut, rightCut) = getRandomSnipRange()
        let insertPoint = Int.random(in: 0..<workingTenome.count)
        
        var reassembledSlices = [Tegment]()
        reassembledSlices.append(workingTenome[..<insertPoint])
        reassembledSlices.append(workingTenome[leftCut..<rightCut])
        reassembledSlices.append(workingTenome[insertPoint...])
        reassembledSlices.append(workingTenome[rightCut...])
        
        var outputTegment = Tenome()
        for slice in reassembledSlices { outputTegment.append(contentsOf: slice) }
        return outputTegment
    }
    
    private func snipAndMoveSequence() -> Tenome {
        if workingTenome.isEmpty { return workingTenome }
        
        let (leftCut, rightCut) = getRandomSnipRange()
        let insertPoint = Int.random(in: 0..<workingTenome.count)
        
        if (leftCut..<rightCut).contains(insertPoint) ||
            insertPoint == leftCut || insertPoint == rightCut
        { return workingTenome }
        
        var reassembledSlices = [Tegment]()
        if insertPoint < leftCut {
            reassembledSlices.append(workingTenome[..<insertPoint])
            reassembledSlices.append(workingTenome[leftCut..<rightCut])
            reassembledSlices.append(workingTenome[insertPoint..<leftCut])
            reassembledSlices.append(workingTenome[rightCut...])
        } else {
            reassembledSlices.append(workingTenome[..<leftCut])
            reassembledSlices.append(workingTenome[leftCut..<rightCut])
            reassembledSlices.append(workingTenome[rightCut..<insertPoint])
            reassembledSlices.append(workingTenome[insertPoint...])
        }
        
        var outputTegment = Tenome()
        for slice in reassembledSlices { outputTegment.append(contentsOf: slice) }
        return outputTegment
    }
    
    private func snipAndCopyReversedSequence() -> Tenome {
        if workingTenome.isEmpty { return workingTenome }
        
        let (leftCut, rightCut) = getRandomSnipRange()
        let insertPoint = Int.random(in: 0..<workingTenome.count)
        
        let theSnippet = Tegment(workingTenome[leftCut..<rightCut].reversed())
        
        var reassembledSlices = [Tegment]()
        reassembledSlices.append(workingTenome[..<insertPoint])
        reassembledSlices.append(theSnippet)
        reassembledSlices.append(workingTenome[insertPoint...])
        
        var outputTegment = Tenome()
        for slice in reassembledSlices { outputTegment.append(contentsOf: slice) }
        return outputTegment
    }
    
    private func snipAndMoveReversedSequence() -> Tenome {
        if workingTenome.isEmpty { return workingTenome }
        
        let (leftCut, rightCut) = getRandomSnipRange()
        let insertPoint = Int.random(in: 0..<workingTenome.count)
        
        if (leftCut..<rightCut).contains(insertPoint) ||
            insertPoint == leftCut || insertPoint == rightCut
        { return workingTenome }
        
        let theSnippet = Tegment(workingTenome[leftCut..<rightCut].reversed())
        
        var reassembledSlices = [Tegment]()
        if insertPoint < leftCut {
            reassembledSlices.append(workingTenome[..<insertPoint])
            reassembledSlices.append(theSnippet)
            reassembledSlices.append(workingTenome[insertPoint..<leftCut])
            reassembledSlices.append(workingTenome[rightCut...])
        } else {
            reassembledSlices.append(workingTenome[..<leftCut])
            reassembledSlices.append(theSnippet)
            reassembledSlices.append(workingTenome[rightCut..<insertPoint])
            reassembledSlices.append(workingTenome[insertPoint...])
        }
        
        var outputTegment = Tenome()
        for slice in reassembledSlices { outputTegment.append(contentsOf: slice) }
        return outputTegment
    }
    
}

extension Mutator {
    static func generateRandomTene() -> Tene {
        let gene = RandomnessGenerator.generateRandomGene()
        let rawComponentSets = getRawComponentSets(for: gene)
        let rawComponentSet = rawComponentSets[0]
        let literalMatch = rawComponentSet[0]
        let token = rawComponentSet.count > 1 ? Character(rawComponentSet[1]) : literalMatch.first!
        let value = rawComponentSet.count > 2 ? String(rawComponentSet[2]) : "V"
        return Tene(String(token), value: value)
    }
    
    static func getRawComponentSets(for genome: Genome) -> [[String]] {
        let rawDataParse = "[LN]\\.|([ABDIWbt])\\(([^\\(]*)\\)\\."
        let rawComponentSets = genome.searchRegex(regex: rawDataParse)
        return rawComponentSets
    }
}
