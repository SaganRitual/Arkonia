import SpriteKit

func hardAssert(_ condition: Bool, _ execute: @escaping (() -> String?)) {
    if !condition {
        guard let e = execute() else { fatalError() }
        Debug.log { return e }
        fatalError(e)
    }
}

struct Debug {
    static func debugStats(startedAt: UInt64, scale: Double) -> Double {
        let stoppedAt = clock_gettime_nsec_np(CLOCK_UPTIME_RAW)
        return constrain(Double(stoppedAt - startedAt) / scale, lo: 0, hi: 1)
    }
}

extension Debug {

    private static let debugLogQueue = DispatchQueue(
        label: "arkonia.log.q", target: DispatchQueue.global()
    )

    private static let startTime = Date()
    private static let cLogMessages = 50000
    private static var logIndex = 0
    private static var logWrapped = false
    private static var logMessages: [String] = Array(repeating: String(), count: cLogMessages)

    // This gives me fine-grained control over log messaging, while
    // leaving out any excess processing needed for the log messages.
    // Not to mention the hundreds of thousands of Strings that come out of it
    static func log(level: Int? = nil, _ execute: () -> String?) {
        let useThisLevel = level ?? Arkonia.debugMessageLevel

        guard useThisLevel >= Arkonia.debugMessageLevel else { return }

        if let e = execute() { log(e) }
    }

    private static func log(_ message: String) {
        debugLogQueue.async {
            logMessages[logIndex] = message
            logIndex = (logIndex + 1) % cLogMessages

            let d = startTime.distance(to: Date())
            let s = String(format: "%f:", d)

            if Arkonia.debugMessageToConsole { print(s, message) }

            if logIndex == 0 { logWrapped = true }
        }
    }

    // Need this for testing, when the test run as a console app, the app quits
    // before the log can finish displaying messages. Have the console app
    // call this function before exiting
    static func waitForLogToClear() {
        debugLogQueue.sync { print("Waiting for log to clear...") }
    }

    static func showLog() {
        print("Log index = \(logIndex)")

        let leftPad = "\(cLogMessages)".count
        let formatString = "% \(leftPad)d:"
        let firstEntry = logWrapped ? logIndex : 0
        let top = logWrapped ? cLogMessages : logIndex

        for ix in 0..<top {
            let wix = (firstEntry + ix) % cLogMessages
            print(String(format: formatString, wix), logMessages[wix])
        }
    }
}
