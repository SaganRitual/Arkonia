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

class PeerGroup: CustomStringConvertible {
    private(set) var theGroup: [TSTestSubject]
    private var indexDistance = 0
    private var pushIndex = 0
    private var popIndex = 0
    private let groupSize = selectionControls.stackTieScoresLimit

    var count: Int { return indexDistance }

    var description: String {
        var d = ""
        var sep = ""
        for progenitor in theGroup { d += sep + "\(progenitor)"; sep = ", " }

        return d + "\n"
    }

    public var stackEmpty: Bool { return indexDistance == 0 }

    init(initialTS: TSTestSubject) {
        theGroup = []
        theGroup.reserveCapacity(groupSize)

        pushBack(initialTS)
    }

    fileprivate func peekFront() -> TSTestSubject {
        precondition(indexDistance > 0, "Stack empty")
        return theGroup[popIndex]
    }

    fileprivate func popFront() -> TSTestSubject {
        precondition(indexDistance > 0, "Stack empty")

        defer {
            popIndex = (popIndex + 1) % groupSize
            indexDistance -= 1
        }

        return theGroup[popIndex]
    }

    fileprivate func pushBack(_ ts: TSTestSubject) {
        precondition(indexDistance <= groupSize, "Stack overflow")

        if theGroup.count < groupSize {
            theGroup.append(ts)
        }

        defer {
            pushIndex = (pushIndex + 1) % groupSize
            indexDistance += 1
        }

        theGroup[pushIndex] = ts
    }
}

class Archive: CustomStringConvertible {

    typealias GroupIndex = Int
    typealias TheArchive = [Int : PeerGroup]

    public enum Comparison: String { case BT, BE, EQ }

    public var description: String { return getDescription() }

    private(set) var comparisonMode = Comparison.BT
    private var theArchive = TheArchive()
    private var theIndex = [GroupIndex]()
    private(set) var referenceTS: TSTestSubject?

    public var currentProgenitor: TSTestSubject? {
        guard let ts: TSTestSubject = getTop() else { return nil }
        return ts
    }

    public func newCandidate(_ ts: TSTestSubject) { keepIfKeeper(ts) }

    public func nextProgenitor() -> TSTestSubject {
        guard var ts: TSTestSubject = getTop() else { preconditionFailure() }
        while isTooDudly(ts) { ts = backtrack() }
        ts.hmSpawnAttempts += 1
        return ts
    }

    public func postInit(aboriginal: TSTestSubject) {
        newGroup(aboriginal)
        setQualifications(reference: aboriginal, op: .BT)
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

private extension Archive {

    func advance(_ ts: TSTestSubject) {
        let hash = makeHash(ts)

        theArchive[hash]!.pushBack(ts)

        // Accept ties until our bucket for this hash is full
        setQualifications(reference: ts, op: .BE)
    }

    func backtrack() -> TSTestSubject {
        guard let (topHash, topGroup): (GroupIndex, PeerGroup) = getTop() else { preconditionFailure() }

        let loafer = theArchive[topHash]!.popFront()

        if topGroup.stackEmpty {
            theIndex.removeLast(); theArchive.removeValue(forKey: topHash)
        }

        // No ties allowed when we have to back up
        guard let ts: TSTestSubject = getTop() else { preconditionFailure() }
        setQualifications(reference: ts, op: .BT)
        print("Back up from \(loafer) to \(ts)")
        return ts
    }

    func getTop() -> TSTestSubject? {
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

    func isTooDudly(_ ts: TSTestSubject) -> Bool {
        return ts.hmSpawnAttempts >= selectionControls.hmSpawnAttempts
    }

    func keepIfKeeper(_ ts: TSTestSubject) {
        guard let ref = referenceTS else { return }
        guard passesCompare(ts, comparisonMode, ref) else { return }
        if peerGroupIsFull(ts) { return }

        let hash = makeHash(ts)
        if theArchive[hash] == nil { newGroup(ts) }
        else { advance(ts) }
    }

    func makeHash(_ ts: TSTestSubject) -> Int {
        var hasher = Hasher()
        hasher.combine(ts.fitnessScore!)
        return hasher.finalize()
    }

    func newGroup(_ ts: TSTestSubject) {
        let hash = makeHash(ts)

        defer { theArchive[hash] = PeerGroup(initialTS: ts) }

        // Keep the index in the proper order
        let currentTS: TSTestSubject? = theIndex.isEmpty ? nil : getTop()
        if currentTS == nil { theIndex.append(hash); return  }

        if let c = currentTS {
            if c.fitnessScore! >= ts.fitnessScore! {
                theIndex.append(hash)
            } else {
                if let ip = theIndex.firstIndex(where: { group in
                    return theArchive[group]!.theGroup[0].fitnessScore! <= ts.fitnessScore!
                }) {
                    theIndex.insert(hash, at: ip)
                } else {
                    theIndex.insert(hash, at: theIndex.endIndex)
                }
            }
        }
    }

    func passesCompare(_ lhs: TSTestSubject, _ op: Comparison, _ rhs: TSTestSubject) -> Bool {
        switch op {
        case .BE: return lhs.fitnessScore! <= rhs.fitnessScore!
        case .BT: return lhs.fitnessScore! < rhs.fitnessScore!
        case .EQ: return lhs.fitnessScore! == rhs.fitnessScore!
        }
    }

    func peerGroupIsFull(_ ts: TSTestSubject) -> Bool {
        let hash = makeHash(ts)
        guard let peerGroup = theArchive[hash] else { return false }
        return peerGroup.count >= selectionControls.maxKeepersPerGeneration
    }

    private func setQualifications(reference ts: TSTestSubject, op: Comparison) {
        referenceTS = ts; comparisonMode = op
    }

}
