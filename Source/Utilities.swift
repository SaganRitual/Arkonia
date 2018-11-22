// Permission is hereby granted, free of charge, to any person obtaining a
//
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

typealias Gene = String
typealias Genome = String
typealias GenomeSlice = Substring
typealias GenomeIndex = String.Index

var A: Character { return "A" } // Activator -- Bool
var B: Character { return "B" } // Generic Bool
var D: Character { return "D" } // Generic Double
var H: Character { return "H" } // Hox gene
var I: Character { return "I" } // Generic Int
var L: Character { return "L" } // Layer
var N: Character { return "N" } // Neuron
var W: Character { return "w" } // Weight -- Double
var b: Character { return "b" } // bias as Double
var t: Character { return "t" } // threshold as Double

let oneInputPort = "A(true)_W(b[1]v[0])_B(b[1]v[0])_T(b[1]v[0])_"
let oneBadInputPort = "A(false)_W(b[1]v[0])_B(b[1]v[0])_T(b[1]v[0])_"

func makeInputPorts(_ howMany: Int, _ good: Bool = true) -> String {
    var theString = String()
    for _ in 0..<howMany {
        theString.append(good ? oneInputPort : oneBadInputPort)
    }
    return theString
}

func makeBadInputPorts(_ howMany: Int) -> String {
    return makeInputPorts(howMany, false)
}

let testGenomes = [
    // One layer, one neuron, increasing numbers of input ports
    "L.N." + makeInputPorts(1),
    "L.N." + makeInputPorts(2),
    "L.N." + makeInputPorts(3),
    "L.N." + makeInputPorts(4),
    "L.N." + makeInputPorts(5),
    
    //One layer, multiple neurons, perfect comm units, so they
    // all aim for the first neuron
    "L.N." + makeInputPorts(2) + "N." + makeInputPorts(2),
    "L.N." + makeInputPorts(2) + "N." + makeInputPorts(2) + "N." + makeInputPorts(2),
    "L.N." + makeInputPorts(3) + "N." + makeInputPorts(3) + "N." + makeInputPorts(3) + "N." + makeInputPorts(3),

    // One layer, one neuron, increasing numbers of input ports
    "L.N." + makeInputPorts(9) + makeInputPorts(1),
    "L.N." + makeInputPorts(8) + makeInputPorts(2),
    "L.N." + makeInputPorts(7) + makeInputPorts(3),
    "L.N." + makeInputPorts(6) + makeInputPorts(4),
    "L.N." + makeInputPorts(5) + makeInputPorts(5),
    "L.N." + makeInputPorts(4) + makeInputPorts(6),
    "L.N." + makeInputPorts(3) + makeInputPorts(7),
    "L.N." + makeInputPorts(2) + makeInputPorts(8),
    "L.N." + makeInputPorts(1) + makeInputPorts(9),

    "L.N.A(true).W(b[1]v[1]).B(b[-4]v[-4]).T(b[2]v[2]).A(true).W(b[1]v[1]).B(b[-4]v[-4]).T(b[2]v[2]).A(false).W(b[1]v[1]).B(b[-4]v[-4]).T(b[2]v[2]).A(true).W(b[1]v[1]).B(b[-4]v[-4]).T(b[2]v[2]).A(true).W(b[1]v[1]).B(b[-4]v[-4]).T(b[2]v[2]).",
    
    "L.N.A(true).W(b[1]v[1]).B(b[-4]v[-4]).T(b[2]v[2]).A(true).W(b[1]v[1]).B(b[-4]v[-4]).T(b[2]v[2]).A(true).W(b[1]v[1]).B(b[-4]v[-4]).T(b[2]v[2]).A(true).W(b[1]v[1]).B(b[-4]v[-4]).T(b[2]v[2]).",
    
    "L.N.A(true).A(true).W(b[2]v[2]).W(b[2]v[2]).W(b[2]v[2]).B(b[8]v[8]).T(b[8]v[8]).",
    "L.N.A(true).A(true).A(true).W(b[2]v[2]).W(b[2]v[2]).W(b[1]v[1]).B(b[7]v[7]).T(b[7]v[7]).",
    
    
    "L.N.A(false).W(b[1]v[1]).B(b[-4]v[-4]).T(b[2]v[2]).A(true).W(b[1]v[1]).B(b[-4]v[-4]).T(b[2]v[2]).", "L.N.A(true).W(b[1]v[1]).W(b[1]v[1]).B(b[-4]v[-4]).T(b[2]v[2]).",

    "L.N.A(true).A(true).W(b[1]v[1]).B(b[1]v[1]).T(b[2]v[2]).", "L.N.A(true).A(true).W(b[1]v[1]).W(b[1]v[1]).B(b[1]v[1]).T(b[2]v[2])",
    "L.N.A(true).W(b[1]v[1]).A(true).W(b[1]v[1]).B(b[1]v[1]).T(b[2]v[2]).", "L.N.B(b[1]v[1]).T(b[2]v[2]).A(true).W(b[1]v[1]).A(true).W(b[1]v[1]).",

    "L.N.A(true).W(b[1]v[1]).B(b[1]v[1]).T(b[100]v[100]).N.A(true).W(b[2]v[2]).B(b[2]v[2]).T(b[100]v[100]).",
    "L.N.A(true).W(b[1]v[1]).B(b[1]v[1]).B(b[37]v[37]).T(b[12]v[12]).T(b[1107]v[1107]).N.A(true).W(b[2]v[2]).A(false).W(b[3]v[3]).A(true).W(b[4]v[4]).A(false).W(b[5]v[5]).A(true).W(b[6]v[6]).A(true).B(b[2]v[2]).T(b[100]v[100]).",
    "L.N.A(false).W(b[1]v[1]).B(b[1]v[1]).B(b[37]v[37]).T(b[12]v[12]).T(b[1107]v[1107]).N.A(true).W(b[2]v[2]).A(false).W(b[3]v[3]).N.A(false).W(b[4]v[4]).A(false).W(b[5]v[5]).A(true).W(b[6]v[6]).A(true).B(b[2]v[2]).T(b[100]v[100])."
]

enum Utilities {
    static var filenameSerialNumber = 0
    static var thereBeNoShowing = true
    
    static func clobbered(_ message: String) { print(message); fatalError(message) }

    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    static func makeFullPath(_ filename: URL) -> URL {
        let filename = String(format: "txt%04d.txt", filenameSerialNumber)
        let fullPath = Utilities.getDocumentsDirectory().appendingPathComponent(filename)
        
        filenameSerialNumber += 1
        return fullPath
    }

//    static func hurl(_ exception: DecodeError) throws { throw exception }
    
    static func load(filename: String) -> [Genome] {
        do {
            let fullPathURL = Utilities.getDocumentsDirectory().appendingPathComponent(filename)
            let jsonString = try String(contentsOf: fullPathURL)
            
            let strands = try JSONDecoder().decode([Genome].self, from: jsonString.data(using: .utf8)!)
            return strands
        } catch {
            print(error)
            fatalError()
        }
    }
    
    static func save(_ strands: [Genome], to filename: String) -> String {
        do {
            let json = try JSONEncoder().encode(strands)
            
            let fullPath = Utilities.getDocumentsDirectory().appendingPathComponent(filename)
            
            filenameSerialNumber += 1
            
            try json.write(to: fullPath)
            return fullPath.absoluteString
        } catch {
            // print(error)
            fatalError()
        }
    }
}

extension Double {
    func sTruncate() -> String {
        let t = Double(truncating: NSNumber(floatLiteral: self))
        return String(format: "%.5f", t)
    }

    func dTruncate() -> Double {
        return Double(sTruncate())!
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

// With deepest gratitude to StackOverflow dudes
// https://stackoverflow.com/users/1786016/arti
// https://stackoverflow.com/users/59541/nate-cook
// https://stackoverflow.com/questions/33290955/regex-capture-group-swift
extension String {
    typealias CaptureElement = Array<String>
    typealias CaptureGroup = Array<CaptureElement>
    func searchRegex (regex: String) -> CaptureGroup {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: NSRegularExpression.Options(rawValue: 0))
            let nsstr = self as NSString
            let all = NSRange(location: 0, length: nsstr.length)
            var hatches = CaptureGroup()
            regex.enumerateMatches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: all)
            {(result : NSTextCheckingResult?, _, _) in
                
                if let r = result?.groups(testedString: self) {
                    hatches.append(r)
                }
//                print("rob", result?.groups(testedString: self))
//                let capturedRange = result!.range(at: 1)
//                if !NSEqualRanges(capturedRange, NSMakeRange(NSNotFound, 0)) {
//                    let theResult = nsstr.substring(with: result!.range(at: 1))
//                    hatches.append(theResult)
//                }
            }
            return hatches
        } catch {
            return CaptureGroup()
        }
    }
}

extension NSTextCheckingResult {
    func groups(testedString:String) -> [String] {
        var groups = [String]()
        for i in  0 ..< self.numberOfRanges {
            let thisRange = self.range(at: i)
            guard let r = Range(thisRange, in: testedString) else { return groups }

            let group = String(testedString[r])
            groups.append(group)
        }
        return groups
    }
}

extension String {
    func isUppercase(_ inputCharacter: Character) -> Bool {
        let inputArray = String(inputCharacter)
        let captureGroup = inputArray.searchRegex(regex: "[A-Z]")
        return !captureGroup.isEmpty
    }
    
    func isLowercase(_ inputCharacter: Character) -> Bool {
        let inputArray = String(inputCharacter)
        let captureGroup = inputArray.searchRegex(regex: "[a-z]")
        return !captureGroup.isEmpty
    }
}

extension Utilities {
    static func applyInterfaces(to genome: Genome) -> GenomeSlice {
        return makeSensesInterface() + genome[...] + makeOutputsInterface()
    }

    static func makeSensesInterface() -> Genome {
        var g = Genome(); g += "L."
        for _ in 0..<Translators.numberOfSenses { g += "N.A(true).W(b[1]v[1]).B(b[0]v[0]).T(b[1000000]v[1000000])." }
        g += "R."; return g
    }
    
    static func makeOutputsInterface() -> Genome {
        var g = Genome(); g += "R.L."
        for _ in 0..<Translators.numberOfMotorNeurons { g += "N.A(true).W(b[1]v[1]).B(b[0]v[0]).T(b[1000000]v[1000000])." }
        return g
    }
    
    static func stripInterfaces(from genome: Genome) -> Genome {
        var stripped = genome[...]
        
        if let headless = stripped.firstIndex(of: "R") {
            let tailless = stripped.lastIndex(of: "R")
            
            // Shouldn't have a lone "R"
            if headless == tailless { fatalError() }
            stripped = stripped[headless..<tailless!]
            return Genome(stripped)
        }
        
        return genome
    }
}

