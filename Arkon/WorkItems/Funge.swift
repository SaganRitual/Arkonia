import CoreGraphics
import Foundation

final class Funge: Dispatchable {
    enum Phase { case lockGrid, getWorldStats, checkSpawnability, execute }

    var currentWorkItem = 0
    weak var scratch: Scratchpad?
    var lockWorkItem: DispatchWorkItem?
    var spawnIfWorkItem: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        print("Funge init")
        self.scratch = scratch

        spawnIfWorkItem = DispatchWorkItem(flags: .barrier, block: checkSpawnability)
    }

    func launch() {
        print("launch")
        guard let scr = scratch else { fatalError() }
        guard let st = scr.stepper else { fatalError() }
        guard let gridCell = st.gridCell else { fatalError() }

        lockWorkItem = gridCell.wiEngage(owner: st.name, require: false) {
            print("engage wi")
            guard let lockedCell = $0 else { return }
            self.onLock(lockedCell)
        }

        print("L2")
        Grid.shared.concurrentQueue.async(execute: lockWorkItem!)
        print("L3")
    }

    func onLock(_ myGridCell: SafeCell?) {
        print("onLock")
        guard let scr = scratch else { fatalError() }
        guard let dp = scr.dispatch else { fatalError() }

        scr.gridCellConnector = myGridCell

        scr.worldStats = World.stats.copy()

        spawnIfWorkItem?.notify(queue: Grid.shared.concurrentQueue, execute: dp.fungeRoute)
        lockWorkItem?.notify(queue: Grid.shared.concurrentQueue, execute: spawnIfWorkItem!)
    }
}

extension Funge {
    func checkSpawnability() {
        print("checkSpawnability")
        guard let scr = scratch else { fatalError() }
        guard let st = scr.stepper else { fatalError() }
        guard let ws = scr.worldStats else { fatalError() }

        let age = ws.currentTime - st.birthday

        scr.isAlive = st.metabolism.fungeProper(age: age)
        scr.canSpawn = st.canSpawn()
        print("isAlive = \(scr.isAlive), canSpawn = \(scr.canSpawn)")
    }
}

extension Metabolism {
    func fungeProper(age: Int) -> Bool {
        print("fungeProper")
        let fudgeFactor: CGFloat = 1
        let joulesNeeded = fudgeFactor * mass

        withdrawFromReady(joulesNeeded)

        let oxygenCost: Int = age < 5 ? 0 : 1
        oxygenLevel -= (CGFloat(oxygenCost) / 60.0)

        print("isAlive = \(fungibleEnergyFullness > 0 && oxygenLevel > 0)")
        return fungibleEnergyFullness > 0 && oxygenLevel > 0
    }
}
