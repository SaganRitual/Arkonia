import CoreGraphics
import Dispatch

final class ComputeMove: Dispatchable {
    internal override func launch() { computeMove() }

    private func computeMove() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        Debug.log(level: 156) { "ComputeMove \(six(st.name))" }

        if ch.plotter == nil { ch.plotter = Plotter(ch) }
        guard let pt = ch.plotter else { fatalError() }

        var entropy: CGFloat = 0

        func a() { pt.plot(b) }
        func b() { Funge.dispatchQueue.async(execute: c) }
        func c() { ch.co2Counter += ch.cellShuttle!.didMove ? 0 : 1; d() }
        func d() { dp.moveSprite() }

        a()
    }

    deinit {
        Debug.log(level: 147) { "ComputeMove deinit \(six(scratch?.name))" }

        // For no particular reason, rebuild the plotter every time
        scratch?.plotter = nil
    }
}
