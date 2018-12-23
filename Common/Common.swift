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

struct GSSelectionControls {
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

extension Array {
    // It's easier for me to think about the breeders as a stack
    mutating func pop() -> Element { return self.removeFirst() }
    mutating func push(_ e: Element) { self.insert(e, at: 0) }
    mutating func popBack() -> Element { return self.removeLast() }
    mutating func pushFront(_ e: Element) { push(e) }
}
