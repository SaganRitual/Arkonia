import SpriteKit

func showDebugLog() {
    Debug.showLog()
}

func six(_ nameThing: ArkonName?) -> String { nameThing == nil ? "<nil>" : "\(nameThing!.nametag)\((nameThing!.setNumber))" }
func six(_ key: HotKey?) -> String { key == nil ? "<nil>" : "tenant \(six(key!.gridPosition))"}
func six(_ point: AKPoint?) -> String { point == nil ? "<nil>" : "\(point!)"}
func six(_ string: String?) -> String { String(string?.prefix(50) ?? "<nothing here>") }

struct Debug {
    static func debugColor(
        _ thorax: SKSpriteNode, _ thoraxColor: SKColor,
        _ nose: SKSpriteNode, _ noseColor: SKColor
    ) {
        if !Arkonia.debugColorIsEnabled { return }
        thorax.color = thoraxColor
        nose.color = noseColor
    }

    static func debugColor(_ stepper: Stepper, _ thoraxColor: SKColor, _ noseColor: SKColor) {
        if !Arkonia.debugColorIsEnabled { return }
        stepper.sprite.color = thoraxColor
        stepper.nose.color = noseColor
    }

    private static let debugLogQueue = DispatchQueue(
        label: "arkonia.log.q", target: DispatchQueue.global(qos: .utility)
    )

    private static let cLogMessages = 10000
    private static var logIndex = 0
    private static var logWrapped = false
    private static var logMessages: [String] = {
        var s = Array(repeating: String(), count: cLogMessages)
        s.reserveCapacity(cLogMessages)
        return s
    }()

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

            if Arkonia.debugMessageToConsole { print(message) }

            if logIndex == 0 { logWrapped = true }
        }
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

    static func showMannaStats() {
        var cCells = 0, cPhotosynthesizing = 0

        for x in -Grid.shared.wGrid..<Grid.shared.wGrid {
            for y in -Grid.shared.hGrid..<Grid.shared.hGrid {
                let p = AKPoint(x: x, y: y)
                let c = Grid.shared.getCell(at: p)

                cCells += 1

                guard let manna = c.manna else {
                    continue
                }

                cPhotosynthesizing += manna.isPhotosynthesizing ? 1 : 0
            }
        }

        print("Manna stats; \(cCells) cells, \(cPhotosynthesizing) photosynthesizing")
    }

    static var cBuckets: Int?
    static var dBuckets = Double(0)
    static var histogram: [Int]?

    static func histogrize(_ value: Double, scale: Int = 10, inputRange: Range<Double>) {
        Debug.log {
            precondition(inputRange == -1.0..<1.0 || inputRange == 0.0..<1.0)

            if(value < inputRange.lowerBound || value > inputRange.upperBound) {
                return "Histogram overflow: value is \(value) range is \(inputRange)"
            }

            if cBuckets == nil {
                cBuckets = scale
                dBuckets = Double(scale)
                histogram = [Int](repeating: 0, count: scale)
            } else {
                precondition(scale == cBuckets!)
            }

            let vv = (value < 1.0) ? value : value - 1e-4   // Because we do get 1.0 sometimes

            let ss: Int
            if inputRange == -1.0..<1.0 {
                let shifted = vv + 1           // Convert scale -1..<1 to 0..<2
                let rescaled = shifted / 2     // Convert scale 0..<2 to 0..<1
                ss = Int(rescaled * dBuckets)  // Convert scale 0..<1 to bucket subscript 0..<cBuckets
            } else {
                ss = Int(vv * dBuckets)        // Convert scale 0..<1 to bucket subscript 0..<cBuckets
            }

            histogram![ss] += 1
            let isItBecauseOfTheArray = Array(histogram!)
            return "H: \(isItBecauseOfTheArray)"
        }
    }
}
