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

// All of these inputs should produce only one empty layer
enum TestDecoderInput {
    static let oneEmptyLayerStrands = [
        "L.",
        
        "L.I(0).",
        "L.I(1).",
        "L.I(2).",
        "L.I(3).",
        "L.I(4).",
        
        "L.N.",
        "L.I(0).N.",
        
        "L.N.I(0).",
        "L.N.I(1).",
        "L.N.I(2).",
        "L.N.I(3).",
        "L.N.I(4).",
        
        "L.N.I(0).N.",
        "L.N.I(1).N.",
        "L.N.I(2).N.",
        "L.N.I(3).N.",
        "L.N.I(4).N.",
        
        "L.N.N.",
        "L.N.N.N.N.N.",
        "L.I(0).I(1).I(0).N.N.N.N.N."
    ]
}
