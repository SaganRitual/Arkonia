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
        func debugEx() -> [T]? { print("Catchall.barrier"); return execute?() }
        func debugOc(_ args: [T]?) { print("Catchall.concurrent"); userOnComplete?(args) }

        Dispatch.Lockable<T>(lockQueue).lock(
            debugEx, debugOc, completionMode
        )
    }
}

extension Stepper {

    func colorize() {
//        print("colorize \(name)")
        World.stats.getTimeSince(birthday, colorize_)
    }

    func colorize_(_ myAge_: Int) {
        let ef = metabolism.fungibleEnergyFullness
        nose.color = ColorGradient.makeColor(Int(ef * 100), 100)

        let baseColor: Int
        if fishNumber < 10 {
            baseColor = 0xFF_00_00
        } else {
            baseColor = (metabolism.spawnEnergyFullness > 0) ?
                ArkonFactory.brightColor : ArkonFactory.standardColor
        }

        let four: CGFloat = 4
        let myAge = CGFloat(myAge_)
        self.sprite.color = ColorGradient.makeColorMixRedBlue(
            baseColor: baseColor,
            redPercentage: metabolism.spawnEnergyFullness,
            bluePercentage: max((four - myAge) / four, 0.0)
        )

        self.sprite.colorBlendFactor = metabolism.oxygenLevel

        World.run(shiftStart)
    }
}
