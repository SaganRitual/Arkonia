import GameplayKit

final class Metabolize: Dispatchable {
    internal override func launch() { aMetabolize() }
}

extension Metabolize {
    func aMetabolize() {
        Debug.log(level: 168) { "Metabolize \(six(scratch.stepper.name))" }

        if Arkonia.debugColorIsEnabled { scratch.stepper.sprite.color = .red }

        scratch.stepper.metabolism.digest()

        scratch.dispatch!.colorize()
    }
}
