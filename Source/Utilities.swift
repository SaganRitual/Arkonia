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
    static func ++ (_ lhs: Character, _ rhs: Character) -> String {
        return String(lhs) + String(rhs)
    }

    static func ++ (_ lhs: Character, _ rhs: String) -> String {
        return String(lhs) + rhs
    }

    static func ++ (_ lhs: String, _ rhs: Character) -> String {
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
    enum GeneSplitType {
        case markerGene, stringGene, doubletGene, doubletValue
    }

    static func splitGene(_ slice: GenomeSlice) -> [GeneComponent] {
        var splitResults = [GeneComponent]()

        for type in [GeneSplitType.markerGene, GeneSplitType.stringGene,
                     GeneSplitType.doubletGene, GeneSplitType.doubletValue] {

            splitResults = splitGene(slice, type)
                        
            if !splitResults.isEmpty { return splitResults }
        }

        preconditionFailure("No match in '\(slice)'")
    }

    // swiftlint:disable cyclomatic_complexity

    static func splitGene(_ slice: GenomeSlice, _ splitType: GeneSplitType) -> [GeneComponent] {
        var geneComponents = [GeneComponent]()

        switch splitType {
        case .markerGene:
            guard let first = slice.firstIndex(where: { "LN".contains($0) })
                else { break }

            geneComponents.append(slice[first...first])

        case .stringGene:
            guard let fmi = slice.firstIndex(where: { "AF".contains($0) })
                else { break }

            let fsi = slice.index(fmi, offsetBy: 2)   // Point to the meat

            guard let eos = slice.lastIndex(of: ")")
                else { break }

            geneComponents.append(slice[fmi...fmi])
            geneComponents.append(slice[fsi..<eos])

        case .doubletGene:
            guard let fmi = slice.firstIndex(where: { "BW".contains($0) })
                else { break }

            // reDoubletGene will capture both a doublet gene and a doublet
            // value. But here I'll discard the result if it's a doublet,
            // because it is a bit more straightforward to allow the .doubletValue
            // case to handle partial genes, that is, doublet values.
            let bmi = slice.index(fmi, offsetBy: 4)   // Point to the base meat
            guard let eob = slice[bmi...].firstIndex(of: "]") else { break }

            let vmi = slice.index(eob, offsetBy: 3)     // Point to the value meat
            guard let eov = slice[vmi...].firstIndex(of: "]") else { break }

            let marker = slice[fmi...fmi]
            let baseline = slice[bmi..<eob]
            let value = slice[vmi..<eov]

            // See comments above under markers
            geneComponents.append(marker)
            geneComponents.append(baseline)
            geneComponents.append(value)

        case .doubletValue:
            let fmi = slice.startIndex

            let bmi = slice.index(fmi, offsetBy: 2)   // Point to the base meat
            guard let eob = slice[bmi...].firstIndex(of: "]") else { break }

            let vmi = slice.index(eob, offsetBy: 3)     // Point to the value meat
            guard let eov = slice[vmi...].firstIndex(of: "]") else { break }

            let baseline = slice[bmi..<eob]
            let value = slice[vmi..<eov]

            // See comments above under markers
            geneComponents.append(baseline)
            geneComponents.append(value)
        }

        return geneComponents
    }

    // swiftlint:enable cyclomatic_complexity

    // With deepest gratitude to Stack Overflow dude
    // https://stackoverflow.com/users/151279/jerry
    // https://stackoverflow.com/a/39048651/1610473
    static func report_memory() -> mach_vm_size_t {
        var info = mach_task_basic_info()
        let MACH_TASK_BASIC_INFO_COUNT = MemoryLayout<mach_task_basic_info>.stride/MemoryLayout<natural_t>.stride
        var count = mach_msg_type_number_t(MACH_TASK_BASIC_INFO_COUNT)

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: MACH_TASK_BASIC_INFO_COUNT) {
                task_info(mach_task_self_,
                          task_flavor_t(MACH_TASK_BASIC_INFO),
                          $0,
                          &count)
            }
        }

        if kerr == KERN_SUCCESS {
//            print("Memory in use (in bytes): \(info.resident_size)")
            return info.resident_size
        }
        else {
            print("Error with task_info(): " +
                (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"))
        }

        return 0
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
        let t = Double(truncating: self as NSNumber)
        return String(format: "%.20f", t)
    }

    func dTruncate() -> Double {
        return Double(sTruncate())!
    }

    static postfix func %% (_ me: Double) -> String { return me.sTruncate() }
}

extension CGFloat {
    func sTruncate() -> String {
        return Double(self).sTruncate()
    }

    func dTruncate() -> Double {
        return Double(self).dTruncate()
    }

    static postfix func %% (_ me: CGFloat) -> String { return me.sTruncate() }
}


extension String {
    func isUppercase(_ inputCharacter: Character) -> Bool {
        return "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(inputCharacter)
    }

    func isLowercase(_ inputCharacter: Character) -> Bool {
        return "abcdefghijklmnopqrstuvwxyz".contains(inputCharacter)
    }
}

typealias Gene = Substring
typealias GeneComponent = Substring
struct GenomeIterator: IteratorProtocol, Sequence {
    typealias Element = Gene
    
    let genome: GenomeSlice
    let recognizedTokens: Substring
    var currentIndex: Gene.Index
    
    init(_ genome: GenomeSlice) {
        self.genome = genome
        self.currentIndex = genome.startIndex;
        self.recognizedTokens = Statics.s.recognizedTokens[...]
    }
    
    public mutating func next() -> Element? {
        guard let c = genome[currentIndex...].firstIndex(where: {
            recognizedTokens.contains($0)
        }) else { return nil }
        
        guard let end = genome[c...].firstIndex(of: "_") else { preconditionFailure() }
        
        defer { currentIndex = genome.index(after: end) }
        return genome[c..<end]
    }
}

func getMeatySlice(_ genome: GenomeSlice) -> GenomeSlice {
    guard let start_ = genome.firstIndex(of: ifm),
          let end = genome.lastIndex(of: ifm) else {
            
        return genome
    }
    
    let start = genome.index(start_, offsetBy: 2)
    
    return genome[start..<end]
}
