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
import SpriteKit

infix operator !!: NilCoalescingPrecedence
func !!<T> (_ theOptional: T?, _ onError: () -> Never) -> T {
    guard let unwrapped = theOptional else { onError() }
    return unwrapped
}

prefix operator %%
prefix func %%<T: Any> (_ theOptional: T?) -> T {
    guard let unwrapped = theOptional else { preconditionFailure() }
    return unwrapped
}

prefix operator ?!
prefix func ?!<T: Any> (_ theOptional: T?) -> T {
    return hardBind(theOptional)
}

func nok<T: Any>(_ theOptional: T?, _ onError: (() -> Never)? = nil) -> T {
    return hardBind(theOptional)
}

func hardBind<T: Any>(_ theOptional: T?, _ onError: (() -> Never)? = nil) -> T {
    guard let unwrapped = theOptional else {
        guard let aBadThingHappened = onError else { preconditionFailure() }
        aBadThingHappened()
    }

    return unwrapped
}

func constrain<T: Numeric & Comparable>(_ a: T, lo: T, hi: T) -> T {
    let capped = min(a, hi)
    return max(capped, lo)
}

// With deepest gratitude to Stack Overflow dude
// https://stackoverflow.com/users/3441734/user3441734
// https://stackoverflow.com/a/44541541/1610473
//
// And Paul Hudson
//
func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

class Log: TextOutputStream {

    static var L = Log()

    var io: DispatchIO?
    var fm = FileManager.default
    var handle: FileHandle?
    let log: URL

    init() {
        log = getDocumentsDirectory().appendingPathComponent("roblog.txt")
        print("Logfile at \(log)")
        do {
            let h = try FileHandle(forWritingTo: log)
            h.truncateFile(atOffset: 0)
            h.seekToEndOfFile()
            self.handle = h

            io = DispatchIO(
                type: .stream, fileDescriptor: h.fileDescriptor,
                queue: DispatchQueue.main, cleanupHandler: { _ in
                    print("huh? closed?")
                }
            )

            io!.setLimit(highWater: 1)

        } catch {
            print("Couldn't open logfile", error)
        }
    }

    deinit { handle?.closeFile() }

    func write(_ string: String) {
//        print(string)
        let martin = Array(string.utf8).withUnsafeBytes { DispatchData(bytes: $0) }

        io!.write(
            offset: 0, data: martin, queue: DispatchQueue.main,
            ioHandler: {  _/*Bool*/, _/*DispatchData*/, _/*Int32*/ in }
        )

        handle!.synchronizeFile()
    }
}
