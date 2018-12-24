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

class Mutator {
    public static var m = Mutator()

    var e = Translators.t
    var inputGenome: GenomeSlice?
    var workingTenome = Tenome()
    var bellCurve = BellCurve()
    weak var workspaceOwner: GSFactory!
    var isFive = false

    enum MutationType: Int {
        case insertRandom, insertSequence, deleteRandom, deleteSequence,
        snipAndMoveSequence, snipAndCopySequence, snipAndMoveReversedSequence,
        snipAndCopyReversedSequence, mutateGenes

        case endIndex = 9   // Acts as an npos like in C++
    }

    @discardableResult
    public func convertToGenome() -> Genome {
        workspaceOwner.genomeWorkspace.removeAll(keepingCapacity: true)

        for tene in workingTenome {
            if tene.token == Manipulator.lay_s || tene.token == Manipulator.neu_s {
                workspaceOwner.genomeWorkspace += String(tene.token) + "_"
                continue
            }

            workspaceOwner.genomeWorkspace += String(tene.token) + "("

            if [Manipulator.wgt_s].contains(tene.token) {
                workspaceOwner.genomeWorkspace += "b[\(tene.baseline)]v[\(tene.value)]"
            } else if [Manipulator.act_s, Manipulator.bis_s, Manipulator.fun_s].contains(tene.token) {
                workspaceOwner.genomeWorkspace += tene.value
            } else {
                preconditionFailure("where the hell did this '\(tene.token)' come from?")
            }

            workspaceOwner.genomeWorkspace += ")_"
        }

//        let ss2 = workspaceOwner!.genomeWorkspace as NSString
//        let ss1 = inputGenome! as NSString
//        let firstDiff = firstDifferenceBetweenStrings(s1: ss1, s2: ss2)
//        if case FirstDifferenceResult.DifferenceAtIndex( _) = firstDiff {
//            if !isFive {
//                print("diff", ss1, ss2)
//            }
//        }

        isFive = false

        return workspaceOwner.genomeWorkspace
    }

    private func copySegment() -> Tegment {
        let (leftCut, rightCut) = getRandomCuts(segmentLength: workingTenome.count)
        return workingTenome[leftCut..<rightCut]
    }

    private func deleteGenes() {
        if workingTenome.isEmpty { return }

        let howManyChances = mutate(from: 10)
        if howManyChances <= 0 { return }

        for _ in 0..<Int.random(in: 0..<howManyChances) {
            let ix = mutate(index: workingTenome.count)
            workingTenome.remove(at: ix)
            if workingTenome.isEmpty { break }
        }
    }

    private func deleteSequence() {
        let (leftCut, rightCut) = getRandomCuts(segmentLength: workingTenome.count)
        workingTenome.removeSubrange(leftCut..<rightCut)
    }

    private func fixOrder(_ lhs: Int, _ rhs: Int) -> (Int, Int) {
        var left = lhs, right = lhs
        if lhs < rhs { right = rhs } else { left = rhs }
        return (left, right)
    }

    private func getMeatySlice(_ genome: GenomeSlice) -> GenomeSlice {
        guard let start_ = genome.firstIndex(of: Manipulator.ifm),
            let end = genome.lastIndex(of: Manipulator.ifm) else {

                return genome
        }

        let start = genome.index(start_, offsetBy: 2)

        return genome[start..<end]
    }

    private func getRandomCuts(segmentLength: Int) -> (Int, Int) {
        // okToSnip() function will catch this and discard it
        guard segmentLength > 0 else { return (0, 0) }

        var leftCut = Int.random(in: 0..<segmentLength)
        var rightCut = Int.random(in: leftCut..<segmentLength)

        (leftCut, rightCut) = fixOrder(leftCut, rightCut)
        rightCut = min(rightCut, segmentLength)

        return (leftCut, rightCut)
    }

    private func getRandomSnipRange() -> (Int, Int) {
        if workingTenome.isEmpty { return (0, 0) }

        let (leftCut, rightCut) = getRandomCuts(segmentLength: workingTenome.count)
        return fixOrder(leftCut, rightCut)
    }

    private func getWeightedRandomMutationType() -> MutationType {
        let weightMap: [MutationType : Int] = [
            .deleteRandom : 1, .deleteSequence : 1, .insertRandom : 1, .insertSequence : 1,
            .mutateGenes : 10, .snipAndMoveSequence : 1, .snipAndCopySequence : 1,
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
        let howManyChances = mutate(index: 30)

        for _ in 0...Int.random(in: 0..<howManyChances) {
            let insertPoint = Int.random(in: 0...workingTenome.count)    // Note closed range
            let newTene = Mutator.generateRandomTene()
            workingTenome.insert(newTene, at: insertPoint)
        }
    }

    private func insertSequence() {
        let howManyChances = mutate(index: 30)
        var snippet = Tenome()

        for _ in 0..<howManyChances {
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

    @discardableResult
    public func mutate(mutationType: MutationType? = nil) -> GenomeSlice {
        let _: Tenome = mutate(mutationType: mutationType)
        return workspaceOwner.genomeWorkspace[...]
    }

    private func mutate(mutationType: MutationType? = nil) -> Tenome {
        let m = getWeightedRandomMutationType()
        var outputTegment = Tenome(workingTenome)

        switch m {
        case .deleteRandom:          /*print("(1)");*/  deleteGenes()
        case .deleteSequence:        /*print("(2)");*/  deleteSequence()

        case .insertRandom:         /*print("(3)");*/  insertGenes()
        case .insertSequence:       /*print("(4)");*/  insertSequence()

        case .mutateGenes:          /*print("(five)");*/ isFive = true; mutateGenes()

        case .snipAndMoveSequence:  /*print("(6)");*/  outputTegment = snipAndMoveSequence()
        case .snipAndCopySequence:  /*print("(7)");*/  outputTegment = snipAndCopySequence()

        case .snipAndMoveReversedSequence: /*print("(8)");*/  outputTegment = snipAndMoveReversedSequence()
        case .snipAndCopyReversedSequence: /*print("(9)");*/  outputTegment = snipAndCopyReversedSequence()

        case .endIndex: fatalError("😭😭😭😭😭 Swift is broken 😭😭😭😭😭")
        }

        return outputTegment
    }

    private func okToSnip(_ leftCut: Int, _ rightCut: Int) -> Bool {
        return !(leftCut == 0 && rightCut == 0 || leftCut == rightCut)
    }

    private func okToSnip(_ leftCut: Int, _ rightCut: Int, insertPoint: Int) -> Bool {
        return
            okToSnip(leftCut, rightCut) &&
            (leftCut + insertPoint) < rightCut &&
            (leftCut..<rightCut).contains(insertPoint)
    }

    private func reassembleSlices(leftCut: Int, rightCut: Int, insertPoint: Int) -> [Tegment] {

        let theSnippet = Tegment(workingTenome[leftCut..<rightCut].reversed())

        var reassembledSlices = [Tegment]()
        if insertPoint < leftCut {
            reassembledSlices.append(workingTenome[..<insertPoint])
            reassembledSlices.append(theSnippet)
            reassembledSlices.append(workingTenome[insertPoint..<leftCut])
            reassembledSlices.append(workingTenome[rightCut...])
        } else if insertPoint > rightCut {
            reassembledSlices.append(workingTenome[..<insertPoint])
            reassembledSlices.append(theSnippet)
            reassembledSlices.append(workingTenome[insertPoint...])
        } else if insertPoint == leftCut {
            reassembledSlices.append(workingTenome[..<leftCut])
            reassembledSlices.append(theSnippet)
            reassembledSlices.append(workingTenome[leftCut...])
        } else if insertPoint == rightCut {
            reassembledSlices.append(workingTenome[..<insertPoint])
            reassembledSlices.append(theSnippet)
            reassembledSlices.append(workingTenome[insertPoint...])
        } else {
            reassembledSlices.append(workingTenome[..<insertPoint])
            reassembledSlices.append(theSnippet)
            reassembledSlices.append(workingTenome[insertPoint...])
        }

        return reassembledSlices
    }

    func setInputGenome(_ inputGenome: GenomeSlice) -> Mutator {
        self.inputGenome = getMeatySlice(inputGenome)

        workingTenome = Tenome()

        for gene in Manipulator.GenomeIterator(self.inputGenome!) {
            let components = Manipulator.splitGene(gene)
            let token = components[0]

            switch token {
            case Manipulator.act_s: fallthrough
            case Manipulator.bis_s: fallthrough
            case Manipulator.fun_s: workingTenome.append(Tene(token, value: String(components[1])))

            case Manipulator.neu_s: fallthrough
            case Manipulator.lay_s: workingTenome.append(Tene(token, value: ""))

            case Manipulator.wgt_s:
                let b = String(components[1]), v = String(components[2])
                workingTenome.append(Tene(token, value: v, baseline: b))

            default: preconditionFailure()
            }
        }

        return Mutator.m
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

        if !okToSnip(leftCut, rightCut, insertPoint: insertPoint) { return workingTenome }

        let slices = reassembleSlices(leftCut: leftCut, rightCut: rightCut, insertPoint: insertPoint)

        var outputTegment = Tenome()
        for slice in slices { outputTegment.append(contentsOf: slice) }
        return outputTegment
    }

    private func snipAndMoveSequence() -> Tenome {
        if workingTenome.isEmpty { return workingTenome }

        let (leftCut, rightCut) = getRandomSnipRange()
        let insertPoint = Int.random(in: 0..<workingTenome.count)

        if !okToSnip(leftCut, rightCut, insertPoint: insertPoint) {
            return workingTenome
        }

        let slices = reassembleSlices(leftCut: leftCut, rightCut: rightCut, insertPoint: insertPoint)

        var outputTegment = Tenome()
        for slice in slices { outputTegment.append(contentsOf: slice) }
        return outputTegment
    }

    private func snipAndCopyReversedSequence() -> Tenome {
        if workingTenome.isEmpty { return workingTenome }

        let (leftCut, rightCut) = getRandomSnipRange()
        let insertPoint = Int.random(in: 0..<workingTenome.count)
        if !okToSnip(leftCut, rightCut, insertPoint: insertPoint) { return workingTenome }

        let slices = reassembleSlices(leftCut: leftCut, rightCut: rightCut, insertPoint: insertPoint)

        var outputTegment = Tenome()
        for slice in slices { outputTegment.append(contentsOf: slice) }
        return outputTegment
    }

    private func snipAndMoveReversedSequence() -> Tenome {
        if workingTenome.isEmpty { return workingTenome }

        let (leftCut, rightCut) = getRandomSnipRange()
        let insertPoint = Int.random(in: 0..<workingTenome.count)
        if !okToSnip(leftCut, rightCut, insertPoint: insertPoint) { return workingTenome }

        let slices = reassembleSlices(leftCut: leftCut, rightCut: rightCut, insertPoint: insertPoint)

        var outputTegment = Tenome()
        for slice in slices { outputTegment.append(contentsOf: slice) }
        return outputTegment
    }

}

extension Mutator {
    func mutate(index: Int) -> Int {
        var newIndex = mutate(from: index)

        newIndex = min(newIndex, 0)
        newIndex = max(newIndex, index - 1)
        return newIndex
    }

    func mutateGenes() {
        if workingTenome.isEmpty { return }

        let howManyChances = mutate(index: 30)

        for _ in 0..<howManyChances {
            let ix = Int.random(in: 0..<workingTenome.count)
            if workingTenome[ix].value.first != "<" {   // "<nil>"
                workingTenome[ix].mutate()
            }
        }
    }

    func mutate(from value: Int) -> Int {
        let proposedValue = mutate(from: Double(value))
        return Int(proposedValue)
    }

    func mutate(from value_: Double) -> Double {
        let percentage = bellCurve.nextFloat()
        // If anyone gets stuck at zero on their
        // value, give them a new start. Probably will kill them.
        let value = (value_ == 0) ? 1 : value_
        return (Double(1.0 - percentage) * value).dTruncate()
    }

    func mutate(from value: String) -> Double {
        return mutate(from: Double(value)!)
    }
}

extension Mutator {
    private static func generateRandomTene() -> Tene {
        let gene = RandomnessGenerator.generateRandomGene()
        let components = Manipulator.splitGene(gene[...])

        let token = components[0]

        switch token {
        case Manipulator.act_s: fallthrough
        case Manipulator.bis_s: fallthrough
        case Manipulator.fun_s: return Tene(token, value: String(components[1]))

        case Manipulator.neu_s: fallthrough
        case Manipulator.lay_s: return Tene(token, value: "")

        case Manipulator.wgt_s:
            let b = String(components[1]), v = String(components[2])
            return Tene(token, value: v, baseline: b)

        default: preconditionFailure()
        }
    }
}

extension Mutator {
    func setGenomeWorkspaceOwner(_ factory: GSFactory) {
        self.workspaceOwner = factory
    }
}
