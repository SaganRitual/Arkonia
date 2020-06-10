import SpriteKit

func hardAssert(_ condition: Bool, _ execute: @escaping (() -> String?)) {
    if !condition {
        guard let e = execute() else { fatalError() }
        Debug.log { return e }
        fatalError(e)
    }
}

func showDebugLog() {
    Debug.showLog()
}

func six(_ string: String?) -> String { String(string?.prefix(50) ?? "<nothing here>") }

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
    private static let cLogMessages = 10000
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

    class Histogram {
        var cBuckets: Int?
        var countdownToLog: Int?
        var dBuckets = Double(0)
        let debugLogInterval = 100
        var histogram: [Int]?

        static let histogramDispatchQueue = DispatchQueue(
            label: "ak.histogram.queue", target: DispatchQueue.global()
        )

        // swiftlint:disable nesting
        // Nesting Violation: Types should be nested at most 1 level deep (nesting)
        enum InputRange { case minusOneToOne, zeroToOne }
        // swiftlint:enable nesting

        func histogrize(
            _ value: Double, scale: Int = 10, inputRange inputRange_: InputRange
        ) {
            Histogram.histogramDispatchQueue.async {
                let inputRange: Range<Double>
                switch inputRange_ {
                case .minusOneToOne: inputRange = Double(-1)..<Double(1)
                case .zeroToOne:     inputRange = Double(0)..<Double(1)
                }

                if(value < inputRange.lowerBound || value > inputRange.upperBound) {
                    Debug.log { "Histogram overflow: value is \(value) range is \(inputRange)" }
                }

                if self.cBuckets == nil {
                    self.cBuckets = scale
                    self.dBuckets = Double(scale)
                    self.histogram = [Int](repeating: 0, count: scale)
                } else {
                    hardAssert(scale == self.cBuckets!) { "hardAssert at \(#file):\(#line)" }
                }

                let vv = (value < 1.0) ? value : value - 1e-4   // Because we do get 1.0 sometimes

                let ss: Int
                switch inputRange_ {
                case .minusOneToOne:
                    let shifted = vv + 1           // Convert scale -1..<1 to 0..<2
                    let rescaled = shifted / 2     // Convert scale 0..<2 to 0..<1
                    ss = Int(rescaled * self.dBuckets)  // Convert scale 0..<1 to bucket subscript 0..<cBuckets

                case .zeroToOne:
                    ss = Int(vv * self.dBuckets)        // Convert scale 0..<1 to bucket subscript 0..<cBuckets
                }

                self.histogram![ss] += 1
                if self.countdownToLog == nil { self.countdownToLog = 0 } else { self.countdownToLog! -= 1 }

                if self.countdownToLog == nil || self.countdownToLog! <= 0 {
                    let showHowMany = 100
                    Debug.log { "H(\(showHowMany)): \(self.histogram!.prefix(showHowMany))" }
                    self.countdownToLog! = self.debugLogInterval
                }
            }
        }
    }
}
