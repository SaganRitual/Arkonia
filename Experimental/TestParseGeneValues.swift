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

enum TestExtras {
    static var inputStrand = "L.I(0)L.I(1)N.L.I(2)N.N.I(1)I(1)B(true)"

    static func createTokenArray(_ token: String, in strand: Strand) -> [StrandIndex] {
        var result = [StrandIndex]()
        var slice = strand[strand.startIndex..<strand.endIndex]
        
        while let startIndex = slice.firstIndex(of: token.first!) {
            result.append(startIndex)
            let newStart = slice.index(after: startIndex)
            slice = slice[newStart...]
        }
        
        return result
    }
}

class TestParseGeneValues {
    var Bs = [StrandIndex]()
    var Ds = [StrandIndex]()
    var Is = [StrandIndex]()
    var Ls = [StrandIndex]()
    var Ns = [StrandIndex]()
    
    var wildInputStrand: String?
    
    var inputStrand: Strand
    var boolCheckValues   = [Bool]()
    var doubleCheckValues = [Double]()
    var intCheckValues    = [Int]()

    init(_ substituteInput: Strand?) {
        if let si = substituteInput { self.inputStrand = si }
        else { (self.inputStrand, self.boolCheckValues, self.doubleCheckValues, self.intCheckValues) =
            TestParseGeneValues.makeRandomStrand()
        }
    }
    
    func setCheckValues() -> (Strand, [Bool]) {
        let pe = "B\\(((?:(true)|(false)))\\)\\."
        
        let matches = self.inputStrand.searchRegex(regex: pe)
        for match in matches {
            self.boolCheckValues.append(match == "true")
        }
        
        return (self.inputStrand, self.boolCheckValues)
    }
    
    func setCheckValues() -> (Strand, [Double]) {
        let pe = "D\\((-?\\d*\\.{0,1}\\d*)\\)\\."
        
        let matches = self.inputStrand.searchRegex(regex: pe)
        for match in matches {
            var decimalPlaces = 0
            if let dot = match.firstIndex(of: ".") {
                decimalPlaces = match.distance(from: dot, to: match.endIndex)
            }
            
            let theDouble__ = Double(match)!
            let theDouble_ = Double(truncating: NSNumber(floatLiteral: theDouble__))
            let funnyAsHell = String(format: "%.\(decimalPlaces)f", theDouble_)
            let theDouble = Double(funnyAsHell)!
            self.doubleCheckValues.append(theDouble)
        }
        
        return (self.inputStrand, self.doubleCheckValues)
    }
    
    func setCheckValues() -> (Strand, [Int]) {
        let pe = "I\\((-?\\d+)\\)\\."
        
        let matches = self.inputStrand.searchRegex(regex: pe)
        for match in matches {
            self.intCheckValues.append(Int(match)!)
        }
        
        return (self.inputStrand, self.intCheckValues)
    }

    static func makeRandomStrand() -> (Strand, [Bool], [Double], [Int]) {
        var theRandomStrand = Strand()
        var boolCheckValues = [Bool]()
        var doubleCheckValues = [Double]()
        var intCheckValues = [Int]()

        let maxLayers = 10, maxNeuronsPerLayer = 10, maxActivatorsPerNeuron = 10, maxWeightsPerNeuron = 10

        for _ in 0..<Int.random(in: 1...maxLayers) {
            theRandomStrand += "L."
            
            let howManyNeurons = Int.random(in: 1...maxNeuronsPerLayer)
            theRandomStrand += "I(\(howManyNeurons))."
            intCheckValues.append(howManyNeurons)
            
            for _ in 0..<howManyNeurons {
                theRandomStrand += "N."
                
                let howManyActivators = Int.random(in: 0...maxActivatorsPerNeuron)
                let howManyWeights = Int.random(in: 0...maxWeightsPerNeuron)
                
                theRandomStrand += "I(\(howManyActivators)).I(\(howManyWeights))."
                intCheckValues.append(contentsOf: [howManyActivators, howManyWeights])
                
                for _ in 0..<howManyActivators {
                    let theRandomBool = Bool.random()
                    theRandomStrand += "B(\(theRandomBool))."
                    boolCheckValues.append(theRandomBool)
                }

                for _ in 0..<(howManyWeights + 2) {
                    let aRandomNumber_ = Double.random(in: -100...100)
                    let aRandomNumber = Double(truncating: NSNumber(floatLiteral: aRandomNumber_))
                    let decimalPlaces = Int.random(in: 0..<6)
                    let formatString = "%.\(decimalPlaces)f"
                    let asString = String(format: formatString, aRandomNumber)
                    theRandomStrand += "D(\(asString))."
                    doubleCheckValues.append(Double(asString)!)
                }
            }
        }
        
        return (theRandomStrand, boolCheckValues, doubleCheckValues, intCheckValues)
    }
    
    init() {
        if let w = wildInputStrand {
            (self.inputStrand, self.doubleCheckValues) =
                TestParseGeneValues(w).setCheckValues()
        } else {
            (self.inputStrand, self.boolCheckValues, self.doubleCheckValues, self.intCheckValues) =
                TestParseGeneValues.makeRandomStrand()
        }
        
        print(self.inputStrand) // Use this as input back into the decoder to make sure it works both ways
       
        Bs = TestExtras.createTokenArray("B", in: self.inputStrand);
        Ds = TestExtras.createTokenArray("D", in: self.inputStrand);
        Is = TestExtras.createTokenArray("I", in: self.inputStrand);
        Ns = TestExtras.createTokenArray("N", in: self.inputStrand);
        Ls = TestExtras.createTokenArray("L", in: self.inputStrand);
    }

    func testParseBool() -> String {
        let decoder = StrandDecoder(self.inputStrand)
        
        for (ss, B) in zip(0..., Bs) {
            let tail = inputStrand[B...].dropFirst(2)
            let paren = tail.firstIndex(of: ")")!
            let meat = tail[..<paren]
            
            let parsed = StrandDecoder.parseBool(meat)
            
            if let p = parsed {
                let correct = boolCheckValues[ss]
                if p != correct {
                    Utilities.clobbered("Mismatch in testParseBool(); expected \(correct), got \(p)")
                }
            } else {
                let meatStart = decoder.toInt(tail.startIndex)
                let meatEnd = decoder.toInt(meat.endIndex)
                Utilities.clobbered("Failed to parse bool in \"\(String(meat))\", [\(meatStart)..<\(meatEnd)]")
            }
        }
        
        return self.inputStrand
    }

    func testParseDouble() -> String {
        let decoder = StrandDecoder(self.inputStrand)
        
        for (ss, D) in zip(0..., Ds) {
            let tail = inputStrand[D...].dropFirst(2)
            let paren = tail.firstIndex(of: ")")!
            let meat = tail[..<paren]
            
            let parsed = StrandDecoder.parseDouble(meat)
            
            if let p = parsed {
                let correct = doubleCheckValues[ss]
                if p != correct {
                    Utilities.clobbered("Mismatch in testParseDouble(); expected \(correct), got \(p)")
                }
            } else {
                let meatStart = decoder.toInt(tail.startIndex)
                let meatEnd = decoder.toInt(meat.endIndex)
                Utilities.clobbered("Failed to parse double in \"\(String(meat))\", [\(meatStart)..<\(meatEnd)]")
            }
        }
        
        return self.inputStrand
    }

    func testParseInt() -> String {
        let decoder = StrandDecoder(self.inputStrand)
        
        for (ss, I) in zip(0..., Is) {
            let tail = inputStrand[I...].dropFirst(2)
            let paren = tail.firstIndex(of: ")")!
            let meat = tail[..<paren]
            
            let parsed = StrandDecoder.parseInt(meat)
            
            if let p = parsed {
                let correct = intCheckValues[ss]
                if p != correct {
                    Utilities.clobbered("Mismatch in testParseInt(); expected \(correct), got \(p)")
                }
            } else {
                let meatStart = decoder.toInt(tail.startIndex)
                let meatEnd = decoder.toInt(meat.endIndex)
                Utilities.clobbered("Failed to parse int in \"\(String(meat))\", [\(meatStart)..<\(meatEnd)]")
            }
        }
        
        return self.inputStrand
    }
}
