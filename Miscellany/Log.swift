import Dispatch
import Foundation

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

class Log {//}: TextOutputStream {
    static var L = Log()

//    var io: DispatchIO?
//    var fm = FileManager.default
//    var handle: FileHandle?
//    let log: URL
//
//    init() {
//        log = getDocumentsDirectory().appendingPathComponent("roblog.txt")
//        print("Logfile at \(log)")
//        do {
//            let h = try FileHandle(forWritingTo: log)
//            h.truncateFile(atOffset: 0)
//            h.seekToEndOfFile()
//            self.handle = h
//
//            io = DispatchIO(
//                type: .stream, fileDescriptor: h.fileDescriptor,
//                queue: DispatchQueue.main, cleanupHandler: { _ in
//                    print("huh? closed?")
//                }
//            )
//
//            io!.setLimit(highWater: 1)
//
//        } catch {
//            print("Couldn't open logfile", error)
//        }
//    }
//
//    deinit { handle?.closeFile() }

    func write(_ string_: String, select: Int) {
        if select > 1 {
            print(string_)
        }
    }

    func write(_ string_: String) {
        write(string_, select: 0)
//        let string = string_ + "\r\n"
//        let martin = Array(string.utf8).withUnsafeBytes { DispatchData(bytes: $0) }
//
//        io!.write(
//            offset: 0, data: martin, queue: DispatchQueue.main,
//            ioHandler: {  _/*Bool*/, _/*DispatchData*/, _/*Int32*/ in }
//        )
//
//        handle!.synchronizeFile()
    }
}
