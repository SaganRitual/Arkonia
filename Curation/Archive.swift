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

class Archive: CustomStringConvertible {

    typealias GroupIndex = Int
    typealias TheArchive = [Int : PeerGroup]

    public var description: String { return getDescription() }

    private(set) var comparisonMode = GSGoalSuite.Comparison.BT
    unowned private let goalSuite: GSGoalSuite
    private(set) var referenceTS: GSSubject?
    private var theArchive = TheArchive()
    private var theIndex = [GroupIndex]()

    init(goalSuite: GSGoalSuite) {
        self.goalSuite = goalSuite
    }

    public var currentProgenitor: GSSubject? {
        guard let gs: GSSubject = getTop() else { return nil }
        return gs
    }

    public func newCandidate(_ gs: GSSubject) { keepIfKeeper(gs) }

    public func nextProgenitor() -> GSSubject? {
        guard var gs: GSSubject = getTop() else { return nil }
        while isTooDudly(gs) {
            // If there's no one left to backtrack to, give up completely
            guard let t = backtrack() else { return nil }
            gs = t
        }

        // Whoever we finally land on, he's getting another
        // chance to breed.
        gs.spawnCount += 1
        return gs
    }

    public func postInit(aboriginal: GSSubject) {
        newGroup(aboriginal)
        setQualifications(reference: aboriginal, op: .BT)
    }
}

private extension Archive {

    func advance(_ gs: GSSubject) {
        let hash = makeHash(gs)

        theArchive[hash]!.pushBack(gs)

        // Accept ties until our bucket for this hash is full
        setQualifications(reference: gs, op: .BE)
    }

    func backtrack() -> GSSubject? {
        guard let (topHash, topGroup): (GroupIndex, PeerGroup) = getTop() else { preconditionFailure() }

        let loafer = theArchive[topHash]!.popFront()

        if topGroup.stackEmpty {
            // If the group at the top is empty, discard it and get the
            // first guy from the next group down.
            theIndex.removeLast(); theArchive.removeValue(forKey: topHash)
        }

        // We backtracked all the way to the beginning and even didn't
        // like the aboriginal. At this point we can either crash or
        // return a nil to main so it can print a friendly message.
        guard let gs: GSSubject = getTop() else { return nil }

        // No ties allowed when we have to back up
        setQualifications(reference: gs, op: .BT)
        print("Back up from \(loafer) to \(gs)")
        return gs
    }

    func getTop() -> GSSubject? {
        guard let (_, topGroup): (GroupIndex, PeerGroup) = getTop() else { return nil }
        let ts = topGroup.peekFront()
        return ts
    }

    func getTop() -> (GroupIndex, PeerGroup)? {
        // Ok if no hash yet; we come here before we've
        // established the aboriginal ancestor.
        guard let topHash = theIndex.last else { return nil }
        guard let topGroup = theArchive[topHash] else { preconditionFailure() }
        return (topHash, topGroup)
    }

    func keepIfKeeper(_ gs: GSSubject) {
        guard let ref = referenceTS else { return }
        guard passesCompare(gs, comparisonMode, against: ref) else { return }

        if peerGroupIsFull(gs) { return }

        let hash = makeHash(gs)
        if theArchive[hash] == nil { newGroup(gs) }
        else { advance(gs) }
    }

    func isTooDudly(_ gs: GSSubject) -> Bool {
        // Never try to back up from thes aboriginal
        if gs.fishNumber == 0 { return false }
        return gs.spawnCount >= goalSuite.selectionControls.hmSpawnAttempts
    }

    func makeHash(_ gs: GSSubject) -> Int {
        var hasher = Hasher()
        hasher.combine(gs.fitnessScore)
        return hasher.finalize()
    }

    func newGroup(_ gs: GSSubject) {
        let hash = makeHash(gs)

        defer { theArchive[hash] = PeerGroup(initialTS: gs, goalSuite: goalSuite) }

        // Keep the index in the proper order
        let currentTS: GSSubject? = theIndex.isEmpty ? nil : getTop()
        if currentTS == nil { theIndex.append(hash); return  }

        if let c = currentTS {
            if c.fitnessScore >= gs.fitnessScore {
                theIndex.append(hash)
            } else {
                if let ip = theIndex.firstIndex(where: { group in
                    return theArchive[group]!.theGroup[0].fitnessScore <= gs.fitnessScore
                }) {
                    theIndex.insert(hash, at: ip)
                } else {
                    theIndex.insert(hash, at: theIndex.endIndex)
                }
            }
        }
    }

    func passesCompare(_ subject: GSSubject, _ op: GSGoalSuite.Comparison, against rhs: GSSubject) -> Bool {
        switch op {
        case .BE: return subject.fitnessScore <= rhs.fitnessScore
        case .BT: return subject.fitnessScore <  rhs.fitnessScore
        case .EQ: return subject.fitnessScore == rhs.fitnessScore
        case .ANY: return true
        }
    }

    func peerGroupIsFull(_ gs: GSSubject) -> Bool {
        let hash = makeHash(gs)
        guard let peerGroup = theArchive[hash] else { return false }
        return peerGroup.count >= goalSuite.selectionControls.maxKeepersPerGeneration
    }

    private func setQualifications(reference gs: GSSubject, op: GSGoalSuite.Comparison) {
        referenceTS = gs; comparisonMode = op
    }
}

private extension Archive {
    func getDescription() -> String {
        var d = "Archive:\n"

        for i in theIndex {
            let s = String(format: "\t0x%X", i)
            d += "\(s): "

            guard let group = theArchive[i] else { preconditionFailure() }
            print(group)
        }

        return d
    }
}
