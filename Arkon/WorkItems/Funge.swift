import CoreGraphics
import Foundation

final class Funge: Dispatchable {
    enum Phase { case lockGrid, getWorldStats, checkSpawnability, execute }

    var currentWorkItem = 0
    weak var scratch: Scratchpad?
    var lockWorkItem: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
//        print("Funge init")
        self.scratch = scratch
    }

    func launch() {
        guard let scr = scratch else { fatalError() }
        guard let st = scr.stepper else { fatalError() }
        guard let gridCell = st.gridCell else { fatalError() }
//        print("launch \(six(st.name))")

        lockWorkItem = gridCell.wiEngage(owner: st.name, require: false) {
            guard let lockedCell = $0 else {
//                print("miss wi")
                return
            }
//            print("engage wi")
            self.onLock(lockedCell)
        }

//        print("L1")
        Grid.shared.concurrentQueue.async(flags: .barrier) {
            self.lockWorkItem?.perform()
        }
//        print("L2")
    }

    func onLock(_ myGridCell: SafeCell?) {
//        print("onLock")
        guard let scr = scratch else { fatalError() }
        guard let dp = scr.dispatch else { fatalError() }

        if myGridCell == nil {
//            print("not locked \(myGridCell!.gridPosition)")
        } else {
//            print("locked \(myGridCell!.gridPosition)")
        }

        scr.gridCellConnector = myGridCell
        scr.worldStats = World.stats.copy()

        checkSpawnability()
        dp.fungeRoute()
    }
}

extension Funge {
    func checkSpawnability() {
//        print("checkSpawnability")
        guard let scr = scratch else { fatalError() }
        guard let st = scr.stepper else { fatalError() }
        guard let ws = scr.worldStats else { fatalError() }

        let age = ws.currentTime - st.birthday

        scr.isAlive = st.metabolism.fungeProper(age: age)
        scr.canSpawn = st.canSpawn()
//        print("isAlive = \(scr.isAlive), canSpawn = \(scr.canSpawn)")
    }
}

extension Metabolism {
    func fungeProper(age: Int) -> Bool {
//        print("fungeProper")
        let fudgeFactor: CGFloat = 1
        let joulesNeeded = fudgeFactor * mass

        withdrawFromReady(joulesNeeded)

        let oxygenCost: Int = age < 5 ? 0 : 1
        oxygenLevel -= (CGFloat(oxygenCost) / 60.0)

//        print("isAlive = \(fungibleEnergyFullness > 0 && oxygenLevel > 0)")
        return fungibleEnergyFullness > 0 && oxygenLevel > 0
    }
}
