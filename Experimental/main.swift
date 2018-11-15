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

extension Double {
    func truncate() -> String {
        let t = Double(truncating: NSNumber(floatLiteral: self))
        return String(format: "%.5f", t)
    }
}

func main() {
    let translators = DecoderTestGeneTranslators()
    let parsers = DecoderTestParsers()

    let geneSelector = [String(A), String(W), String(b), String(t)]
    
    func truncate(_ d: Double) -> String {
        let t = Double(truncating: NSNumber(floatLiteral: d))
        return String(t)
    }
    
    let inputStrand: Strand = {
        var workingStrand = Strand()
        for _ in 0..<100 {
            let ss = Int.random(in: 0..<geneSelector.count)

            switch ss {
            case 0: workingStrand += "A(\(Bool.random()))."
            case 1: workingStrand += "W(\(Double.random(in: -100...100).truncate()))."
            case 2: workingStrand += "b(\(Double.random(in: -100...100).truncate()))."
            case 3: workingStrand += "t(\(Double.random(in: -100...100).truncate()))."
            default: fatalError()
            }
        }

        return workingStrand
    }()
    
    print(inputStrand)
    
    let decoder = Decoder(parsers: parsers, translators: translators)
    _ = decoder.setInput(to: inputStrand)
    decoder.decode()
}

main()
