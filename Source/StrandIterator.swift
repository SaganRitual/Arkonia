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

prefix operator *       // Character at current index
prefix operator ^       // Current index as a String index
prefix operator ^^      // Current index as an Int

class StrandIterator {
    let input: String
    var iterator: String.Iterator
    var token: Character
    var currentIndex: String.Index
    
    var eodu: Bool { return currentIndex == input.endIndex }
    
    init(input: String, token: Character) {
        self.input = input
        self.token = token
        self.iterator = input.makeIterator()
        self.currentIndex = input.startIndex
        
        // Get lined up on the first token of my type
        if let s = *self, s != token { _ = next() }
    }
    
    func advance(_ howMany: Int = 1) -> Character? {
        guard self.currentIndex != input.endIndex else { return nil }
        
        var result: Character?
        
        for _ in 0..<howMany {
            result = iterator.next();
            self.currentIndex = self.input.index(after: self.currentIndex)
        }
        
        return result
    }
    
    func next() -> Character? {
        var nextCharacter: Character?

        if let cc = *self, cc == token { _ = advance() }
        
        while let cc = *self, cc != self.token {
            nextCharacter = advance()
        }
        
        if let ss = *self, ss == self.token { return ss }
        
        defer { if self.currentIndex != input.endIndex { _ = advance() } }
        
        return nextCharacter
    }
    
    static prefix func ^^(_ it: StrandIterator) -> String.IndexDistance {
        return it.input.distance(from: it.input.startIndex, to: ^it)
    }

    static prefix func ^(_ it: StrandIterator) -> String.Index {
        return it.currentIndex
    }
    
    static prefix func *(_ it: StrandIterator) -> Character? {
        let index = ^it
        return (index == it.input.endIndex) ? nil : it.input[index]
    }
}
