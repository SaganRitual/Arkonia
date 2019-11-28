import Dispatch
import Foundation

//class Log {
//    class L {
//
//    }
//}
//
//extension Log.L {
//    static var logFile: URL? {
//        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd-MM-yyyy"
//        let dateString = formatter.string(from: Date())
//        let fileName = "\(dateString).log"
//        return documentsDirectory.appendingPathComponent(fileName)
//    }
//
//    static func write(_ message: String, level : Int = 0) {
//        guard let logFile = logFile else { return }
//        if select <= 1 { return }
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm:ss"
//        let timestamp = formatter.string(from: Date())
//        guard let data = (timestamp + ": " + message + "\n").data(using: String.Encoding.utf8) else { return }
//
//        if FileManager.default.fileExists(atPath: logFile.path) {
//            if let fileHandle = try? FileHandle(forWritingTo: logFile) {
//                fileHandle.seekToEndOfFile()
//                fileHandle.write(data)
//                fileHandle.closeFile()
//            }
//        } else {
//            try? data.write(to: logFile, options: .atomicWrite)
//        }
//    }
//}

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
//    let syncQueue = DispatchQueue(
//        label: "arkonia.log.queue",
//        qos: .utility,
//        attributes: .concurrent,
//        target: DispatchQueue.global(qos: .utility)
//    )
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

    let minimumLevel = 17
    func write(_ string_: String, level: Int? = nil) {
        let useThisLevel = level ?? minimumLevel

        if useThisLevel >= minimumLevel {
            print(string_)
        }
    }

//    func write(_ string: String) {
//        syncQueue.async { write_(string) }
//    }
//
//    func write_(_ string_: String) {
////        write(string_, level : 0)
//        let string = string_ + "\r\n"
//        let martin = Array(string.utf8).withUnsafeBytes { DispatchData(bytes: $0) }
//
//        io!.write(
//            offset: 0, data: martin, queue: DispatchQueue.main,
//            ioHandler: {  _/*Bool*/, _/*DispatchData*/, _/*Int32*/ in }
//        )
//
//        handle!.synchronizeFile()
//    }
}
