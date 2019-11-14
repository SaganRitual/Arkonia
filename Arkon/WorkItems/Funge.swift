import CoreGraphics
import Foundation

final class Funge: Dispatchable {
    enum Phase { case lockGrid, getWorldStats, checkSpawnability, execute }

    var currentWorkItem = 0
    weak var scratch: Scratchpad?
    var stats: World.StatsCopy!
    var workItem: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        print("Funge(\(scratch.stepper!.name))")

        self.scratch = scratch

        workItem = DispatchWorkItem(flags: .init(), block: checkSpawnability)
    }

    func launch() {
        guard let sp = scratch else { fatalError() }
        guard let sc = sp.safeCell else { fatalError() }
        guard let st = sp.stepper else { fatalError() }

        let gridCell = GridCell.at(sc)

        let lockWorkItem = gridCell.wiEngage(owner: st.name, require: false) {
            guard let connector = $0 else { return }
            self.onLock(connector)
        }

        Grid.shared.concurrentQueue.async(execute: lockWorkItem)
    }

    func onLock(_ myGridCell: SafeCell?) {
        guard let sp = scratch else { fatalError() }
        sp.gridCellConnector = myGridCell

        stats = World.stats.copy()
    }
}

extension Funge {
    func checkSpawnability() {
        guard let sp = scratch else { fatalError() }
        guard let st = sp.stepper else { fatalError() }

        let age = stats.currentTime - st.birthday

        sp.isAlive = st.metabolism.fungeProper(age: age)
        sp.canSpawn = st.canSpawn()
    }
}

extension Metabolism {
    func fungeProper(age: Int) -> Bool {
        let fudgeFactor: CGFloat = 1
        let joulesNeeded = fudgeFactor * mass

        withdrawFromReady(joulesNeeded)

        let oxygenCost: Int = age < 5 ? 0 : 1
        oxygenLevel -= (CGFloat(oxygenCost) / 60.0)

        return fungibleEnergyFullness > 0 && oxygenLevel > 0
    }
}
