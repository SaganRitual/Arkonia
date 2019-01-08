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

extension Archive {

public class PeerGroup: CustomStringConvertible {

    private(set) var theGroup = [GSSubject]()
    unowned private let goalSuite: GSGoalSuite
    private var indexDistance = 0
    private var pushIndex = 0
    private var popIndex = 0
    private let peerGroupLimit: Int

    var count: Int { return indexDistance }

    var description: String {
        var d = ""
        var sep = ""
        for progenitor in theGroup { d += sep + "\(progenitor)"; sep = ", " }

        return d + "\n"
    }

    public var stackEmpty: Bool { return indexDistance == 0 }

    init(initialTS: GSSubject, goalSuite: GSGoalSuite) {
        self.goalSuite = goalSuite
        peerGroupLimit = ArkonCentral.sel.peerGroupLimit
        theGroup.reserveCapacity(peerGroupLimit)

        pushBack(initialTS)
    }

    public func peekFront() -> GSSubject {
        precondition(indexDistance > 0, "Stack empty")
        return theGroup[popIndex]
    }

    public func popFront() -> GSSubject {
        precondition(indexDistance > 0, "Stack empty")

        defer {
            popIndex = (popIndex + 1) % peerGroupLimit
            indexDistance -= 1
        }

        return theGroup[popIndex]
    }

    public func pushBack(_ gs: GSSubject) {
        precondition(indexDistance <= peerGroupLimit, "Stack overflow")

        if theGroup.count < peerGroupLimit {
            theGroup.append(gs)
        }

        defer {
            pushIndex = (pushIndex + 1) % peerGroupLimit
            indexDistance += 1
        }

        theGroup[pushIndex] = gs
    }
}

}
