import Dispatch

final class Disengage: Dispatchable {
    internal override func launch() {
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }
        Debug.debugColor(st, .cyan, .cyan)

        ch.engagerKey = nil
        dp.engage()
    }

}
