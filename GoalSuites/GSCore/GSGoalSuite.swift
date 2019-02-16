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
    public enum Comparison: String { case ANY, BE, BT, EQ }

    private(set) var curator: Curator?
    public var factory: GSFactory
    public var tester: GSTesterProtocol

    public var description: String { return "GSGoalSuite" }

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

    class func setSelectionControls() {
        preconditionFailure("Subclasses must override this function")
    }
}
