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

class TSTestSubject: CustomStringConvertible {
    static var fishNumber = 0

    var fitnessScore: Double?
    var howManySpawnAttempts = 0
    var fishNumber = 0

    var description: String { return "TS(\(fishNumber), \(fitnessScore!))" }

    init(_ score: Double) {
        fitnessScore = score
        fishNumber = TSTestSubject.fishNumber
        TSTestSubject.fishNumber += 1
    }
}

class SelectionControls {
    let archiveDepth = 10
    let archiveWidth = 3
    let howManySpawnAttempts = 2
}

var selectionControls = SelectionControls()

class Archive: CustomStringConvertible {
    typealias PeerGroup = [TSTestSubject]
    typealias GroupIndex = Int
    typealias TheArchive = [Int : PeerGroup]

    enum Comparison: String { case BT, BE, EQ }
    enum Disposition: String { case backtrack, nonLoser, sameGuy, winner }

    public var description: String { return getDescription() }

    private(set) var comparisonMode = Comparison.BT
    private(set) var disposition = Disposition.winner
    private var theArchive = TheArchive()
    private var theIndex = [GroupIndex]()
    private(set) var referenceTS: TSTestSubject?

    public func newCandidate(_ ts: TSTestSubject) { keepIfKeeper(ts) }

    public func nextProgenitor() -> TSTestSubject {
        var ts: TSTestSubject = getTop()
        while isTooDudly(ts) { ts = backtrack() }
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
            var sep = ""
            for progenitor in group { d += sep + "\(progenitor)"; sep = ", " }

            d += "\n"
        }

        return d
    }
}

private extension Archive {

    // nextGroup() and
    func advance(_ ts: TSTestSubject) {
        let hash = makeHash(ts)

        theArchive[hash]!.append(ts)

        // Accept ties until our bucket for this hash is full
        comparisonMode = .BE
    }

    func backtrack() -> TSTestSubject {
        var (topHash, topGroup) = getTop()

        if topGroup.isEmpty {
            theIndex.removeLast(); theArchive.removeValue(forKey: topHash)
        } else { topGroup.removeFirst() }

        // No ties allowed when we have to back up
        comparisonMode = .BT
        return getTop()
    }

    func getTop() -> TSTestSubject {
        var (_, topGroup) = getTop()

        let ts = topGroup[0]
        return ts
    }

    func getTop() -> (GroupIndex, PeerGroup) {
        guard let topHash = theIndex.last else { preconditionFailure() }
        guard let topGroup = theArchive[topHash] else { preconditionFailure() }
        return (topHash, topGroup)
    }

    func isTooDudly(_ ts: TSTestSubject) -> Bool {
        return ts.howManySpawnAttempts >= selectionControls.howManySpawnAttempts
    }

    func keepIfKeeper(_ ts: TSTestSubject) {
        guard let ref = referenceTS else { return }
        guard passesCompare(ts, comparisonMode, ref) else { return }
        if peerGroupIsFull(ts) { return }

        defer { advance(ts) }
        
        let hash = makeHash(ts)
        if theArchive[hash] == nil { newGroup(ts) }
    }

    func makeHash(_ ts: TSTestSubject) -> Int {
        var hasher = Hasher()
        hasher.combine(ts.fitnessScore!)
        return hasher.finalize()
    }

    func newGroup(_ ts: TSTestSubject) {
        let hash = makeHash(ts)
        theArchive[hash] = PeerGroup(arrayLiteral: ts)
        theIndex.append(hash)
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
        return peerGroup.count >= selectionControls.archiveWidth
    }

    private func setQualifications(reference ts: TSTestSubject, op: Comparison) {
        referenceTS = ts; comparisonMode = op
    }

}

let archive = Archive()
let ts = [
    TSTestSubject(42.0), TSTestSubject(41.0), TSTestSubject(40.0), TSTestSubject(39.0),
    TSTestSubject(41.0), TSTestSubject(41.0), TSTestSubject(39.0), TSTestSubject(39.0),
    TSTestSubject(39.0), TSTestSubject(39.0), TSTestSubject(39.0), TSTestSubject(42.0),
]

archive.postInit(aboriginal: ts[0])
ts.forEach { archive.newCandidate($0) }

print(archive)
