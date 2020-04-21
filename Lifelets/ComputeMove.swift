import CoreGraphics
import Dispatch

final class ComputeMove: Dispatchable {
    internal override func launch() { computeMove() }

    private func computeMove() {
        Debug.log(level: 156) { "ComputeMove \(six(scratch.stepper.name))" }

        if scratch.plotter == nil { scratch.plotter = Plotter(scratch) }
        guard let pt = scratch.plotter else { fatalError() }

        var entropy: CGFloat = 0

        func a() { pt.plot(b) }
        func b() { TickLife.dispatchQueue.async(execute: c) }
        func c() { scratch.dispatch!.moveSprite() }

        a()
    }

    deinit {
        Debug.log(level: 147) { "ComputeMove deinit \(six(scratch?.name))" }

        // For no particular reason, rebuild the plotter every time
        scratch?.plotter = nil
    }
}
