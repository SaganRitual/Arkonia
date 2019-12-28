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

    static var minimumLevel = 69
    static let useFile = false

    var io: DispatchIO?
    var fm: FileManager! = FileManager.default
    var handle: FileHandle?
    var log: URL!

    let serialQueue = DispatchQueue(
        label: "arkonia.log.queue",
        target: DispatchQueue.global(qos: .utility)
    )

    init() {
        guard Log.useFile == true else { return }

        log = getDocumentsDirectory().appendingPathComponent("roblog.txt")
        print("Logfile at \(log!)")
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

        fatalError("Take this out if you want to use the logfile")
    }

    deinit { handle?.closeFile() }

    func write(_ string_: String, level: Int? = nil) {
        let useThisLevel = level ?? Log.minimumLevel

        if useThisLevel >= Log.minimumLevel {
            if Log.useFile {
                serialQueue.async { self.write_(string_) }
            } else {
                print(string_)
            }
        }
    }

    func write_(_ string_: String) {
        let string = string_ + "\r\n"
        let martin = Array(string.utf8).withUnsafeBytes { DispatchData(bytes: $0) }

        io!.write(
            offset: 0, data: martin, queue: DispatchQueue.main,
            ioHandler: {  _/*Bool*/, _/*DispatchData*/, _/*Int32*/ in }
        )

        handle!.synchronizeFile()
    }
}
