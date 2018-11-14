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
    
    var wildInputStrand: String? = "L.I(6).N.I(10).I(1).B(false).B(true).B(false).B(false).B(true).B(true).B(true).B(true).B(false).B(true).D(-57.20712).D(2.26167).D(-45.73700).N.I(2).I(7).B(false).B(false).D(73.3934).D(31.0).D(-3.87103).D(67.0057).D(-16.95238).D(70).D(-7).D(-71.3).D(71.5140).N.I(10).I(8).B(false).B(false).B(true).B(false).B(true).B(false).B(false).B(true).B(true).B(false).D(-53.672).D(-71.6).D(-94.73).D(-91.46).D(93.02060).D(23.6332).D(53.6071).D(-93.14).D(22.8807).D(87.8165).N.I(2).I(0).B(false).B(false).D(-0.80623).D(0.70).N.I(9).I(3).B(true).B(true).B(true).B(false).B(false).B(false).B(false).B(true).B(true).D(81).D(84.632).D(2).D(84.91).D(-50.37648).N.I(4).I(7).B(true).B(true).B(false).B(false).D(-61.1).D(-67.52).D(11.90537).D(-15.9).D(11.2238).D(78.2).D(14.79).D(-5).D(-88.670).L.I(10).N.I(5).I(5).B(false).B(false).B(false).B(true).B(false).D(-13).D(-12.162).D(-70.8722).D(-2.19).D(6.29).D(-10.63).D(74.936).N.I(2).I(1).B(false).B(true).D(80.9).D(90).D(-13).N.I(10).I(4).B(true).B(false).B(false).B(true).B(true).B(true).B(true).B(true).B(true).B(false).D(-10).D(-57.3).D(-6.0673).D(-12.5249).D(20).D(-52.2089).N.I(8).I(10).B(true).B(false).B(true).B(true).B(true).B(true).B(true).B(false).D(-50.0).D(44.53).D(37.7239).D(-72.16).D(-81.19175).D(-37.87).D(78.2188).D(63.67).D(-8).D(-19).D(81.160).D(-23.15025).N.I(4).I(9).B(false).B(false).B(false).B(false).D(-78).D(52.055).D(-33).D(12.5944).D(-30.83).D(-67.48082).D(-94.81696).D(38.159).D(30.3).D(16.448).D(66.4).N.I(9).I(4).B(true).B(false).B(true).B(true).B(false).B(true).B(false).B(true).B(false).D(92.1898).D(50.6179).D(-65.08904).D(70.040).D(-36.79165).D(96.36).N.I(3).I(0).B(true).B(false).B(false).D(-53.2).D(-99.6).N.I(6).I(7).B(true).B(false).B(true).B(true).B(false).B(false).D(88.2763).D(91.8560).D(21.4).D(67.1).D(95.392).D(-91.59).D(-78.1).D(-44.8).D(17).N.I(2).I(4).B(false).B(false).D(-48.15).D(46).D(-86.25).D(49.7781).D(-27.838).D(-83.474).N.I(4).I(1).B(false).B(true).B(true).B(false).D(11.847).D(79).D(-24.601).L.I(2).N.I(9).I(6).B(true).B(false).B(false).B(true).B(true).B(false).B(false).B(false).B(true).D(37.402).D(67.2).D(11.5).D(-99.1).D(42.81).D(-62.1).D(-39.0).D(-26.9176).N.I(4).I(10).B(true).B(false).B(true).B(true).D(-79.7).D(47.1).D(79.63).D(95.76721).D(-31.7).D(-90.75073).D(-55.58).D(33).D(5).D(-26.3606).D(-7).D(-35).L.I(10).N.I(8).I(0).B(true).B(false).B(false).B(false).B(true).B(false).B(false).B(true).D(94.10873).D(-65.45560).N.I(5).I(9).B(false).B(true).B(true).B(true).B(true).D(-37).D(18.2273).D(21.821).D(8.9168).D(75.8013).D(30.212).D(1.1851).D(-91.8402).D(75.1418).D(42.6223).D(43.2928).N.I(3).I(8).B(true).B(false).B(true).D(47.354).D(-2.1).D(22.79016).D(-34).D(59.804).D(18.1900).D(-62.61).D(88).D(-80.18058).D(24).N.I(9).I(8).B(true).B(true).B(false).B(false).B(true).B(false).B(false).B(true).B(false).D(-20.756).D(-11.7815).D(44.3451).D(32.83).D(-12.3).D(37.1891).D(85.14773).D(-82.8945).D(-0.008).D(-8.8369).N.I(9).I(5).B(true).B(false).B(true).B(true).B(true).B(false).B(false).B(true).B(true).D(-95.6148).D(-27).D(-22.88).D(21.09).D(-88.947).D(-19.77).D(39.8).N.I(9).I(0).B(true).B(true).B(false).B(false).B(true).B(false).B(true).B(true).B(true).D(-49.234).D(-90.396).N.I(10).I(0).B(false).B(false).B(false).B(false).B(true).B(true).B(false).B(true).B(false).B(true).D(-73.96).D(77.67016).N.I(10).I(9).B(false).B(true).B(false).B(true).B(false).B(false).B(true).B(false).B(true).B(false).D(9.67073).D(11).D(-17.8).D(-0.64798).D(43.481).D(9.7667).D(7.8).D(-42.120).D(30.79).D(-90.482).D(-71.92779).N.I(6).I(10).B(false).B(true).B(false).B(true).B(true).B(true).D(52.8).D(47).D(-13.313).D(-50.155).D(-68.800).D(-65).D(-4.40307).D(-37.4132).D(-32.4).D(-5.4).D(36.2).D(-59).N.I(0).I(1).D(-78).D(-58).D(81.179)."
    
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
            
            let theDouble__ = Double(match)!
            let theDouble_ = Double(truncating: NSNumber(floatLiteral: theDouble__))
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
        
        return (theRandomStrand, doubleCheckValues)
    }
    
    init() {
        if let w = wildInputStrand {
            (self.inputStrand, self.doubleCheckValues) =
                TestParseGeneValues(w).getStrandStats()
        } else {
            (self.inputStrand, self.doubleCheckValues) =
                TestParseGeneValues.makeRandomStrand()
        }
        
        print(self.inputStrand) // Use this as input back into the decoder to make sure it works both ways
       
        Bs = TestExtras.createTokenArray("B", in: self.inputStrand);
        Ds = TestExtras.createTokenArray("D", in: self.inputStrand);
        Is = TestExtras.createTokenArray("I", in: self.inputStrand);
        Ns = TestExtras.createTokenArray("N", in: self.inputStrand);
        Ls = TestExtras.createTokenArray("L", in: self.inputStrand);
    }

    func testParseDouble() {
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
    }
}
