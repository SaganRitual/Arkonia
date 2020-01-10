import SpriteKit

func showDebugLog() {
    Debug.showLog()
}

struct Debug {
    static let debugColorIsEnabled = false

    static func debugColor(
        _ thorax: SKSpriteNode, _ thoraxColor: SKColor,
        _ nose: SKSpriteNode, _ noseColor: SKColor
    ) {
        if !Debug.debugColorIsEnabled { return }
        thorax.color = thoraxColor
        nose.color = noseColor
    }

    static func debugColor(_ stepper: Stepper, _ thoraxColor: SKColor, _ noseColor: SKColor) {
        if !Debug.debugColorIsEnabled { return }
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

    static func log(_ message: String, level: Int? = nil) {
        debugLogQueue.async {
            let useThisLevel = level ?? Arkonia.debugMessageLevel

            if useThisLevel >= Arkonia.debugMessageLevel {
                logMessages[logIndex] = message
                logIndex = (logIndex + 1) % cLogMessages

                if logIndex == 0 { logWrapped = true }
            }
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
}
