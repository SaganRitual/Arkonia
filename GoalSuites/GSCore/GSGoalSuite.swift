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

class GSGoalSuite {
    static var selectionControls: SelectionControls!

    public enum Comparison: String { case ANY, BE, BT, EQ }

    private(set) var curator: Curator?
    public var factory: GSFactory
    public var tester: GSTesterProtocol

    public var selectionControls: SelectionControls { return GSGoalSuite.selectionControls }

    init(factory: GSFactory, tester: GSTesterProtocol) {
        self.factory = factory
        self.tester = tester

        factory.postInit(suite: self)
        tester.postInit(suite: self)
    }

    public func run() -> GSSubject? {
        curator = Curator(goalSuite: self)
        return curator!.select()
    }

    class func setSelectionControls() -> SelectionControls {
        preconditionFailure("Subclasses must override this function")
    }
}

extension GSGoalSuite {
    struct SelectionControls {
        var howManySenses = 5
        var howManyMotorNeurons = 20
        var howManyGenerations = 30000
        var howManyGenes = 200
        var howManyLayersInStarter = 5
        var howManySubjectsPerGeneration = 100
        var theFishNumber = 0
        var dudlinessThreshold = 1
        var peerGroupLimit = 2
        var maxKeepersPerGeneration = 2
        var hmSpawnAttempts = 2
    }
}
