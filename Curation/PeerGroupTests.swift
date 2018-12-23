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

class Archive {}

public class GSSubject {
    static var theFishNumber = 0

    let fishNumber: Int

    init() { fishNumber = GSSubject.theFishNumber; GSSubject.theFishNumber += 1 }
}

public class GSGoalSuite {
    var selectionControls = GSSelectionControls()
}

public class GSSelectionControls {
    let peerGroupLimit = 5
}

public class PeerGroupTests: CustomStringConvertible {
    let mockGoalSuite = GSGoalSuite()
    let mockSubjects: [GSSubject]
    var pg: Archive.PeerGroup

    public var description: String { return "PeerGroup tester; \(self.pg.count) Arkons on stack" }

    init() {
        mockSubjects = (0..<10).map { _ in return GSSubject() }
        pg = Archive.PeerGroup(initialTS: mockSubjects[0], goalSuite: mockGoalSuite)
    }

    func test() {
        precondition(pg.count == 1, "Init should have pushed the initial Arkon to the stack")

        let a = pg.popFront()
        precondition(pg.stackEmpty, "Init should have pushed only one Arkon")
        precondition(a.fishNumber == mockSubjects[0].fishNumber,
                     "Init should have pushed this particular Arkon -> \(mockSubjects[0].fishNumber)")

        for i in 4..<8 { pg.pushBack(mockSubjects[i]) }
        for i in 4..<8 {
            let a = pg.peekFront()
            precondition(a.fishNumber == i, "Pushing in the wrong order, or something")
            _ = pg.popFront()
        }
    }

}
