import Foundation

typealias GoCall = () -> Void

protocol Dispatchable {
    var scratch: Scratchpad? { get }

    func launch()
}

extension Dispatchable {
}

class Scratchpad {
    var canSpawn = false
    var battle: (Stepper, Stepper)?
    weak var dispatch: Dispatch?
    var gridCellConnector: SafeConnectorProtocol?
    var isAlive = false
    var safeCell: SafeCell?
    var worldStats: World.Stats?
    weak var stepper: Stepper?
}

final class Dispatch {
    var gridCellConnector: SafeConnectorProtocol?
    var safeCell: SafeCell { return (gridCellConnector as? SafeCell)! }
    var senseGrid: SafeSenseGrid { return (gridCellConnector as? SafeSenseGrid)! }
    var stage: SafeStage { return (gridCellConnector as? SafeStage)! }

    var currentTask: Dispatchable!
    let name = UUID().uuidString
    var pendingOwnerCallback: GoCall?
    weak var stepper: Stepper!

    var workItemApoptosize: DispatchWorkItem?
    var workItemColorize: DispatchWorkItem?
    var workItemEat: DispatchWorkItem?
    var workItemFunge: DispatchWorkItem?
    var workItemFungeRoute: DispatchWorkItem?
    var workItemGroup = DispatchGroup()
    var workItemMetabolize: DispatchWorkItem?
    var workItemParasitize: DispatchWorkItem?
    var workItemShift: DispatchWorkItem?
    var workItemWangkhi: DispatchWorkItem?

    var scratch = Scratchpad()

    init(_ stepper: Stepper? = nil) {
        scratch.dispatch = self
        scratch.stepper = stepper

        workItemApoptosize = DispatchWorkItem(block: apoptosize)
        workItemColorize   = DispatchWorkItem(block: colorize)
        workItemEat        = DispatchWorkItem(block: eat)
        workItemFunge      = DispatchWorkItem(block: funge)
        workItemFungeRoute = DispatchWorkItem(block: fungeRoute)
        workItemMetabolize = DispatchWorkItem(block: metabolize)
        workItemParasitize = DispatchWorkItem(block: parasitize)
        workItemShift      = DispatchWorkItem(block: shift)
        workItemWangkhi    = DispatchWorkItem(block: wangkhi)

        workItemMetabolize!.notify(queue: Grid.shared.concurrentQueue, execute: workItemColorize!)
        workItemColorize!.notify(queue: Grid.shared.concurrentQueue, execute: workItemShift!)
        workItemParasitize!.notify(queue: Grid.shared.concurrentQueue, execute: workItemFunge!)

        workItemFunge!.notify(queue: Grid.shared.concurrentQueue, execute: workItemFungeRoute!)
        Grid.shared.serialQueue.async(execute: workItemFunge!)
    }

    func go() { funge() }
}

extension Dispatch {
    func apoptosize() {
        currentTask = Apoptosize(scratch)
        currentTask.launch()
    }

    func colorize() {
        currentTask = Colorize(scratch)
        currentTask.launch()
    }

    func eat() {
        currentTask = Eat(scratch)
        currentTask.launch()
    }

    func funge() {
        currentTask = Funge(scratch)
        currentTask.launch()
    }

    private func fungeRoute() {
        if !scratch.isAlive { apoptosize(); return }

        if !scratch.canSpawn { metabolize(); return }

        wangkhi()
    }

    func metabolize() {
        currentTask = Metabolize(scratch)
        currentTask.launch()
    }

    func parasitize() {
        currentTask = Parasitize(scratch)
        currentTask.launch()
    }

    func shift() {
        currentTask = Shifter(scratch)
        currentTask.launch()
    }

    func wangkhi() {
        currentTask = WangkhiEmbryo(scratch)
        currentTask.launch()
    }
}
