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

func makeSlice(_ string: String, _ startIndex: Int, _ endIndex: Int) -> StrandSlice {
    let rangeStart = string.index(string.startIndex, offsetBy: startIndex)
    let rangeEnd = string.index(string.startIndex, offsetBy: endIndex)
    return string[rangeStart..<rangeEnd]
}

func makeSlice(_ string: String, _ startIndex: StrandIndex, _ rangeEnd: Int) -> StrandSlice {
    let endIndex = string.index(startIndex, offsetBy: rangeEnd)
    return string[startIndex..<endIndex]
}

func makeSlice(_ slice: StrandSlice, _ startIndex: StrandIndex, _ rangeEnd: Int) -> StrandSlice {
    let endIndex = slice.index(startIndex, offsetBy: rangeEnd)
    return slice[startIndex..<endIndex]
}

enum TestExtras {
    static var inputStrand: String { get {
        print("huh?"); return "L.I(0)L.I(1)N.L.I(2)N.N.I(1)I(1)B(true)" } }

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

extension NSTextCheckingResult {
    func groups(testedString:String) -> [String] {
        var groups = [String]()
        for i in  0 ..< self.numberOfRanges
        {
            let group = String(testedString[Range(self.range(at: i), in: testedString)!])
            groups.append(group)
        }
        return groups
    }
}

// With deepest gratitude to StackOverflow dudes
// https://stackoverflow.com/users/1786016/arti
// https://stackoverflow.com/users/59541/nate-cook
// https://stackoverflow.com/questions/33290955/regex-capture-group-swift
extension String {
    func searchRegex (regex: String) -> Array<String> {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: NSRegularExpression.Options(rawValue: 0))
            let nsstr = self as NSString
            let all = NSRange(location: 0, length: nsstr.length)
            var hatches : Array<String> = Array<String>()
            regex.enumerateMatches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: all)
            {(result : NSTextCheckingResult?, _, _) in
                
                let capturedRange = result!.range(at: 1)
                if !NSEqualRanges(capturedRange, NSMakeRange(NSNotFound, 0)) {
                    let theResult = nsstr.substring(with: result!.range(at: 1))
                    hatches.append(theResult)
                }
            }
            return hatches
        } catch {
            return Array<String>()
        }
    }
}

infix operator ~~=
infix operator ~~+
extension String {
    // With deepest gratitude to Paul Hudson
    // https://twitter.com/twostraws
    // https://www.hackingwithswift.com/articles/108/how-to-use-regular-expressions-in-swift
    //
    static func ~= (lhs: String, rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
        let range = NSRange(location: 0, length: lhs.utf16.count)
        return regex.firstMatch(in: lhs, options: [], range: range) != nil
    }
    
    // With deepest gratitude to StackOverflow denizen Martn R
    // https://stackoverflow.com/users/1187415/martin-r
    // https://stackoverflow.com/a/27880748/1610473
    //
    static func ~~= (stringToSearch: String, patternToMatch: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: patternToMatch)
            let results = regex.matches(in: stringToSearch,
                                        range: NSRange(stringToSearch.startIndex..., in: stringToSearch))
            return results.map {
                String(stringToSearch[Range($0.range, in: stringToSearch)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
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
    var doubleCheckValues = [Double]()
    
    init(_ substituteInput: Strand) { inputStrand = substituteInput }
    
    func getStrandStats() -> (Strand, [Double]) {
        let pe = "D\\((-?\\d*\\.{0,1}\\d*)\\)\\."
        
        let matches = self.inputStrand.searchRegex(regex: pe)
        for match in matches {
            var decimalPlaces = 0
            if let dot = match.firstIndex(of: ".") {
                decimalPlaces = match.distance(from: dot, to: match.endIndex)
            }
            
            let theDouble_ = Double(match)!
            let funnyAsHell = String(format: "%.\(decimalPlaces)f", theDouble_)
            let theDouble = Double(funnyAsHell)!
            self.doubleCheckValues.append(theDouble)
        }
        
        return (self.inputStrand, self.doubleCheckValues)
    }
    
    static func makeRandomStrand() -> (Strand, [Double]) {
        var theRandomStrand = Strand()
        var doubleCheckValues = [Double]()
        
        let maxLayers = 10, maxNeuronsPerLayer = 10, maxActivatorsPerNeuron = 10, maxWeightsPerNeuron = 10

        for _ in 0..<Int.random(in: 1...maxLayers) {
            theRandomStrand += "L."
            
            let howManyNeurons = Int.random(in: 1...maxNeuronsPerLayer)
            theRandomStrand += "I(\(howManyNeurons))."
            
            for _ in 0..<howManyNeurons {
                theRandomStrand += "N."
                
                let howManyActivators = Int.random(in: 0...maxActivatorsPerNeuron)
                let howManyWeights = Int.random(in: 0...maxWeightsPerNeuron)
                
                theRandomStrand += "I(\(howManyActivators)).I(\(howManyWeights))."
                
                for _ in 0..<howManyActivators { theRandomStrand += "B(\(Bool.random().description))." }
                for _ in 0..<(howManyWeights + 2) {
                    let aRandomNumber = Double.random(in: -100...100)
                    let decimalPlaces = Int.random(in: 0..<6)
                    theRandomStrand += "D(\(String(format: "%.\(decimalPlaces)f", aRandomNumber)))."
                    doubleCheckValues.append(aRandomNumber)
                }
            }
        }
        
        return (theRandomStrand, doubleCheckValues)
    }
    
    init() {
        if let w = wildInputStrand {
            (self.inputStrand, self.doubleCheckValues) =
                TestParseGeneValues(w).getStrandStats()
            
        } else {
            print("random")
            (self.inputStrand, self.doubleCheckValues) =
                TestParseGeneValues.makeRandomStrand()
            
        }
       
        print(self.inputStrand)
        
        Bs = TestExtras.createTokenArray("B", in: self.inputStrand); print(Bs.count)
        Ds = TestExtras.createTokenArray("D", in: self.inputStrand); print(Ds.count)
        Is = TestExtras.createTokenArray("I", in: self.inputStrand); print(Is.count)
        Ns = TestExtras.createTokenArray("N", in: self.inputStrand); print(Ns.count)
        Ls = TestExtras.createTokenArray("L", in: self.inputStrand); print(Ls.count)
    }

    func testParseDouble() {
        let decoder = StrandDecoder(self.inputStrand)
        
        for (ss, D) in zip(0..., Ds) {
            let tail = inputStrand[D...].dropFirst(2)
            let paren = tail.firstIndex(of: ")")!
            let meat = tail[..<paren]
            
            print("length is ", tail.distance(from: tail.startIndex, to: paren))
            
            let parsed = StrandDecoder.parseDouble(meat)
            print("m", String(meat), "p", parsed ?? "<huh?>", "ss", ss)
            
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
    }
}
