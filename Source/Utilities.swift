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

var act: Character { return "A" } // Activator -- Bool
var bis: Character { return "B" } // Bias -- Stubble
var fun: Character { return "F" } // Function -- string
var hox: Character { return "H" } // Hox gene -- haven't worked out the type yet
var lay: Character { return "L" } // Layer
var neu: Character { return "N" } // Neuron
var thr: Character { return "T" } // Threshold -- Stubble
var ifm: Character { return "R" } // Interface marker
var wgt: Character { return "W" } // Weight -- Stubble

var actb: String { return "A_" } // Activator -- Bool
var bisb: String { return "B_" } // Bias -- Stubble
var funb: String { return "F_" } // Function -- string
var hoxb: String { return "H_" } // Hox gene -- haven't worked out the type yet
var layb: String { return "L_" } // Layer
var neub: String { return "N_" } // Neuron
var thrb: String { return "T_" } // Threshold -- Stubble
var ifmb: String { return "R_" } // Interface marker
var wgtb: String { return "W_" } // Weight -- Stubble

let oneInputPort = "A(true)_W(b[1]v[0])_B(b[1]v[0])_T(b[1]v[0])_"
let oneBadInputPort = "A(false)_W(b[1]v[0])_B(b[1]v[0])_T(b[1]v[0])_"

enum ParseSubscript: Int {
    case stubbleBaseline = 1, stubbleValue = 2
}

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
    "L_N_" + makeInputPorts(1),
    "L_N_" + makeInputPorts(2),
    "L_N_" + makeInputPorts(3),
    "L_N_" + makeInputPorts(4),
    "L_N_" + makeInputPorts(5),
    
    //One layer, multiple neurons, perfect comm units, so they
    // all aim for the first neuron
    "L_N_" + makeInputPorts(2) + "N_" + makeInputPorts(2),
    "L_N_" + makeInputPorts(2) + "N_" + makeInputPorts(2) + "N_" + makeInputPorts(2),
    "L_N_" + makeInputPorts(3) + "N_" + makeInputPorts(3) + "N_" + makeInputPorts(3) + "N_" + makeInputPorts(3),

    // One layer, one neuron, increasing numbers of input ports
    "L_N_" + makeInputPorts(9) + makeInputPorts(1),
    "L_N_" + makeInputPorts(8) + makeInputPorts(2),
    "L_N_" + makeInputPorts(7) + makeInputPorts(3),
    "L_N_" + makeInputPorts(6) + makeInputPorts(4),
    "L_N_" + makeInputPorts(5) + makeInputPorts(5),
    "L_N_" + makeInputPorts(4) + makeInputPorts(6),
    "L_N_" + makeInputPorts(3) + makeInputPorts(7),
    "L_N_" + makeInputPorts(2) + makeInputPorts(8),
    "L_N_" + makeInputPorts(1) + makeInputPorts(9),

    "L_N_A(true)_W(b[1]v[1])_B(b[-4]v[-4])_T(b[2]v[2])_A(true)_W(b[1]v[1])_B(b[-4]v[-4])_T(b[2]v[2])_A(false)_W(b[1]v[1])_B(b[-4]v[-4])_T(b[2]v[2])_A(true)_W(b[1]v[1])_B(b[-4]v[-4])_T(b[2]v[2])_A(true)_W(b[1]v[1])_B(b[-4]v[-4])_T(b[2]v[2])_",
    
    "L_N_A(true)_W(b[1]v[1])_B(b[-4]v[-4])_T(b[2]v[2])_A(true)_W(b[1]v[1])_B(b[-4]v[-4])_T(b[2]v[2])_A(true)_W(b[1]v[1])_B(b[-4]v[-4])_T(b[2]v[2])_A(true)_W(b[1]v[1])_B(b[-4]v[-4])_T(b[2]v[2])_",
    
    "L_N_A(true)_A(true)_W(b[2]v[2])_W(b[2]v[2])_W(b[2]v[2])_B(b[8]v[8])_T(b[8]v[8])_",
    "L_N_A(true)_A(true)_A(true)_W(b[2]v[2])_W(b[2]v[2])_W(b[1]v[1])_B(b[7]v[7])_T(b[7]v[7])_",
    
    
    "L_N_A(false)_W(b[1]v[1])_B(b[-4]v[-4])_T(b[2]v[2])_A(true)_W(b[1]v[1])_B(b[-4]v[-4])_T(b[2]v[2])_", "L_N_A(true)_W(b[1]v[1])_W(b[1]v[1])_B(b[-4]v[-4])_T(b[2]v[2])_",

    "L_N_A(true)_A(true)_W(b[1]v[1])_B(b[1]v[1])_T(b[2]v[2])_", "L_N_A(true)_A(true)_W(b[1]v[1])_W(b[1]v[1])_B(b[1]v[1])_T(b[2]v[2])",
    "L_N_A(true)_W(b[1]v[1])_A(true)_W(b[1]v[1])_B(b[1]v[1])_T(b[2]v[2])_", "L_N_B(b[1]v[1])_T(b[2]v[2])_A(true)_W(b[1]v[1])_A(true)_W(b[1]v[1])_",

    "L_N_A(true)_W(b[1]v[1])_B(b[1]v[1])_T(b[100]v[100])_N_A(true)_W(b[2]v[2])_B(b[2]v[2])_T(b[100]v[100])_",
    "L_N_A(true)_W(b[1]v[1])_B(b[1]v[1])_B(b[37]v[37])_T(b[12]v[12])_T(b[1107]v[1107])_N_A(true)_W(b[2]v[2])_A(false)_W(b[3]v[3])_A(true)_W(b[4]v[4])_A(false)_W(b[5]v[5])_A(true)_W(b[6]v[6])_A(true)_B(b[2]v[2])_T(b[100]v[100])_",
    "L_N_A(false)_W(b[1]v[1])_B(b[1]v[1])_B(b[37]v[37])_T(b[12]v[12])_T(b[1107]v[1107])_N_A(true)_W(b[2]v[2])_A(false)_W(b[3]v[3])_N_A(false)_W(b[4]v[4])_A(false)_W(b[5]v[5])_A(true)_W(b[6]v[6])_A(true)_B(b[2]v[2])_T(b[100]v[100])_"
]

// With deepest gratitude to Stack Overflow dude
// https://stackoverflow.com/users/3441734/user3441734
// https://stackoverflow.com/a/44541541/1610473
class Log: TextOutputStream {
    
    static var L = Log()
    
    var fm = FileManager.default
    let log: URL
    var handle: FileHandle?
    
    init() {
        log = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("roblog.txt")
        print("Logfile at \(log)")
        if let h = try? FileHandle(forWritingTo: log) {
            h.truncateFile(atOffset: 0)
            h.seekToEndOfFile()
            self.handle = h
        } else {
            print("Couldn't open logfile")
        }
    }
    
    deinit { handle?.closeFile() }

    func write(_ string: String) {
        if let h = self.handle {
            h.write(string.data(using: .utf8)!)
        } else {
            try? string.data(using: .utf8)?.write(to: log)
        }
    }
}

precedencegroup CharacterAdditionPrecedence {
    assignment: true
    lowerThan: AdditionPrecedence
    higherThan: AssignmentPrecedence
    associativity: left
}

infix operator ++: CharacterAdditionPrecedence

extension Character {
    static func ++(_ lhs: Character, _ rhs: Character) -> String {
        return String(lhs) + String(rhs)
    }
    
    static func ++(_ lhs: Character, _ rhs: String) -> String {
        return String(lhs) + rhs
    }
    
    static func ++(_ lhs: String, _ rhs: Character) -> String {
        return lhs + String(rhs)
    }
}

enum SelectionError: Error {
    case nonViableBrain
}

enum Utilities {
    static var filenameSerialNumber = 0
    static var thereBeNoShowing = true
    
    static func clobbered(_ message: String) { print(message); fatalError(message) }
        
    static func splitGenome(_ slice: GenomeSlice) -> [String] {
        // Because we leave a trailing _ in the string, components()
        // gives us back an empty entry; ditch it.
        let sliceThing = String(slice).components(separatedBy: "_").dropLast()
        let stringThing = sliceThing.map { String($0) }
        return stringThing
    }
    
    enum GeneSplitType {
        case markerGene, stringGene, doubletGene, doubletValue
    }
    
    static func splitGene(_ slice: GenomeSlice) -> [String] {
        var splitResults = [String]()

        for type in [GeneSplitType.markerGene, GeneSplitType.stringGene,
                     GeneSplitType.doubletGene, GeneSplitType.doubletValue] {
        
            splitResults = splitGene(slice, type)
                        if !splitResults.isEmpty { /*print("match; type \(type)", slice); */return splitResults }
        }
        
        preconditionFailure("No match in '\(slice)'")
    }
    
    static func splitGene(_ slice_: GenomeSlice, _ splitType: GeneSplitType) -> [String] {
        let slice = String(slice_)
        var geneComponents = [String]()
        
        switch splitType {
        case .markerGene:
            let reMarkers = "^([LN])$"
            let markers = slice.searchRegex(regex: reMarkers)
            if markers.isEmpty { return geneComponents }

            // Regex result is the match array for the entire input
            // string. result[0] contains the first match, which
            // itself is an array of strings. result[0][0] is the
            // full literal match of the search pattern, and result[0][1]
            // is the first capture.
            geneComponents.append(markers[0][1])
            return geneComponents

        case .stringGene:
            let reStringGene = "^([AF])\\(([a-z]+)\\)$"
            let stringGeneComponents = slice.searchRegex(regex: reStringGene)
            if stringGeneComponents.isEmpty { /*print("Not a string gene", slice);*/ return geneComponents }

            geneComponents.append(stringGeneComponents[0][1])
            geneComponents.append(stringGeneComponents[0][2])
//            print("String gene returns \(geneComponents)")
            return geneComponents

        case .doubletGene:
            let reDoubletGene = "([BW])\\(b\\[([^\\]]+)\\]v\\[([^\\]]+)\\]\\)"
            let doubletGeneComponents = slice.searchRegex(regex: reDoubletGene)
            if doubletGeneComponents.isEmpty { /*print("Not a doublet gene", slice);*/ return geneComponents }
            
            // reDoubletGene will capture both a doublet gene and a doublet
            // value. But here I'll discard the result if it's a doublet,
            // because it is a bit more straightforward to allow the .doubletValue
            // case to handle partial genes, that is, doublet values.
            if doubletGeneComponents[0].count != 4 { return geneComponents }
//            print("is a doublet: \(doubletGeneComponents)")

            // See comments above under markers
            geneComponents.append(doubletGeneComponents[0][1])
            geneComponents.append(doubletGeneComponents[0][2])
            geneComponents.append(doubletGeneComponents[0][3])
            return geneComponents
        
        case .doubletValue:
            let reDoubletValue = "b\\[([^\\]]+)\\]v\\[([^\\]]+)\\]"
            let doubletValueComponents = slice.searchRegex(regex: reDoubletValue)
            if doubletValueComponents.isEmpty { return geneComponents }

            // See comments above under markers
            geneComponents.append(doubletValueComponents[0][1])
            geneComponents.append(doubletValueComponents[0][2])
            return geneComponents
        }
    }

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

    static func hurl(_ exception: SelectionError) throws { throw exception }
    
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

postfix operator %%
extension Double {
    func sTruncate() -> String {
        let t = Double(truncating: NSNumber(floatLiteral: self))
        return String(format: "%.10f", t)
    }

    func dTruncate() -> Double {
        return Double(sTruncate())!
    }
    
    static postfix func %%(_ me: Double) -> String { return me.sTruncate() }
}

extension CGFloat {
    func sTruncate() -> String {
        return Double(self).sTruncate()
    }
    
    func dTruncate() -> Double {
        return Double(self).dTruncate()
    }
    
    static postfix func %%(_ me: CGFloat) -> String { return me.sTruncate() }
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
            print("regex problem:", error)
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
        var g = Genome(); g += layb
        for _ in 0..<selectionControls.howManySenses { g += "N_A(true)_W(b[1.0]v[1.0])_B(b[0.0]v[0.0])_" }
        g += ifmb; return g
    }
    
    static func makeOutputsInterface() -> Genome {
        var g = Genome(); g += ifmb + layb
        for _ in 0..<selectionControls.howManyMotorNeurons { g += "N_A(true)_W(b[1.0]v[1.0])_B(b[0.0]v[0.0])_" }
        return g
    }
    
    static func stripInterfaces(from genome: Genome) -> Genome {
        var stripped = genome[...]
        
        if let headless = stripped.firstIndex(of: ifm) {
            let tailless = stripped.lastIndex(of: ifm)
            
            // Shouldn't have a lone "R"
            if headless == tailless { fatalError() }
            stripped = stripped[headless..<tailless!]
            return Genome(stripped)
        }
        
        return genome
    }
}

