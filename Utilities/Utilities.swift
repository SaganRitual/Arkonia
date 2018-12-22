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

class RollingAverage {
    let depth: Int
    var values = [Double]()

    var ss_ = 0
    var ss: Int {
        get { return ss_ }
        set { ss_ = newValue % depth }
    }

    init(depth: Int) {
        self.depth = depth
    }

    func addSample(_ newValue: Double) -> Double? {
        if values.count < depth {
            values.append(newValue)
            print("nv", newValue)
            return nil
        }

        values[ss] = newValue; ss += 1
//        print("valsodfdl", values.sorted().dropFirst(2))
        return values.sorted().dropFirst(2).reduce(0.0, +) / Double(depth - 2)
    }
}

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

    class MemoryTracker {
        let idString: String
        var start: mach_vm_size_t? = Utilities.report_memory()

        init(_ idString: String = "Memory") {
            self.idString = idString
        }

        func close(_ idString: String = "Memory") {
            guard let s = start else { return }
            let end = Utilities.report_memory()
            var sign = 1
            let used = (s > end) ? s - end : end - s
            if s > end { sign = -1 }
            start = nil
            print("Total: \(end / 1024 / 1024)MB, memory used in \(idString) \(sign > 0 ? "" : "-")\(used)")
        }

        deinit { close() }
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

func nilstr<T: CustomStringConvertible>(_ theOptional: T?, defaultString: String = "<nil>") -> String {
    var output = defaultString
    if let t = theOptional { output = "\(t)" }
    return output
}

postfix operator <!>

// This is the make-no-mistake-I-intend-a-crash way to force unwrap
postfix func <!><T> (_ theThing: T?) -> T {
    switch theThing {
    case .some(let good): return good
    case .none: preconditionFailure("Bang!")
    }
}

postfix operator %%
extension Double {
    func sciTruncate(_ length: Int) -> String {
        let t = Double(truncating: self as NSNumber)
        return String(format: "%.\(length)e", t)
    }

    func sTruncate() -> String {
        let t = Double(truncating: self as NSNumber)
        return String(format: "%.20f", t)
    }

    func sTruncate(_ length: Int) -> String {
        let t = Double(truncating: self as NSNumber)
        return String(format: "%.\(length)f", t)
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
