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

enum GeneType: CaseIterable {
    /// Activator function
    case activator
    /// Bias to add to output signal
    case bias
    /// Special connection to the motor layer
    case downConnector
    /// Segment multiplier, as in real life
    case hox
    /// Experimental segment wrapper, causes the genes to be seen as
    /// a single gene by the Mutator, such that they never get scrambled
    /// internally, but move together as a unit
    case lock
    /// Container for neurons
    case layer
    /// In person
    case neuron
    /// Experimental, set custom behavior or something, I don't know. I'm thinking
    /// something like a "no more than five layers" policy, or something.
//    case policy
    /// Skip over genes as specified, ignoring them completely
//    case skipAnyType
    /// Skip over one particular type of gene, ignoring them completely.
    ///
    /// Like this:
    ///
    /// input = `AbbbAcccAbbbAdbc`, cToSkip = 3, typetoSkip = A
    ///
    /// output = `bbb ccc bbb Adbc` (sans spaces; that's for readability).
//    case skipOneType
    /// The usual way neurons connect
    case upConnector

    #if K_RUN_DT_GENOME
    /// For testing; the payload is an Int
    case mockGene
    #endif
}
