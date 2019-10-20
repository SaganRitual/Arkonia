import GameplayKit

struct Catchall {
    static let lockQueue = DispatchQueue(
        label: "arkonia.lock.catchall", qos: .default,
        attributes: DispatchQueue.Attributes.concurrent,
        target: DispatchQueue.global()
    )

    static func lock<T>(
        _ execute: Dispatch.Lockable<T>.LockExecute? = nil,
        _ userOnComplete: Dispatch.Lockable<T>.LockOnComplete? = nil,
        _ completionMode: Dispatch.CompletionMode = .concurrent
    ) {
        Dispatch.Lockable<T>(lockQueue).lock(
            execute, userOnComplete, completionMode
        )
    }
}

extension Arkon {
    func colorize(
        metabolism: Metabolism, age: TimeInterval,
        onComplete: @escaping LockVoid.LockOnComplete
    ) {
        print("dl colorize")
        func workItem() -> [Void]? { colorize_(metabolism, age); return nil }
        Catchall.lock(workItem, onComplete)
    }

    func colorize_(_ metabolism: Metabolism, _ age: TimeInterval) {
        let ef = metabolism.fungibleEnergyFullness
        nose.color = ColorGradient.makeColor(Int(ef * 100), 100)

        let baseColor: Int
        if selectoid.fishNumber < 10 {
            baseColor = 0xFF_00_00
        } else {
            baseColor = (metabolism.spawnEnergyFullness > 0) ?
                Arkon.brightColor : Arkon.standardColor
        }

        let four: CGFloat = 4
        self.sprite.color = ColorGradient.makeColorMixRedBlue(
            baseColor: baseColor,
            redPercentage: metabolism.spawnEnergyFullness,
            bluePercentage: max((four - CGFloat(age)) / four, 0.0)
        )

        self.sprite.colorBlendFactor = metabolism.oxygenLevel
    }
}
