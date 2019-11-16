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
    weak var dispatch: Dispatch?
    var gridCell: GridCell?
    var gridCellConnector: SafeConnectorProtocol?
    var isAlive = false
    var worldStats: World.StatsCopy?
    weak var stepper: Stepper?

    var safeCell:  SafeCell { return (gridCellConnector as? SafeCell)! }
    var senseGrid: SafeSenseGrid { return (gridCellConnector as? SafeSenseGrid)! }
    var stage:     SafeStage { return (gridCellConnector as? SafeStage)! }

//    init() { print("scratchpad") }
}

final class Dispatch {
    var currentTask: Dispatchable!
    let name = UUID().uuidString

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

    var workItems = [DispatchWorkItem]()

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

//        workItemMetabolize!.notify(queue: <#T##DispatchQueue#>, execute: <#T##DispatchWorkItem#>)
//        workItemColorize!.notify(queue: Grid.shared.concurrentQueue, execute: workItemShift!)
//        workItemParasitize!.notify(queue: Grid.shared.concurrentQueue, execute: workItemFunge!)

//        workItemFunge!.notify(queue: Grid.shared.concurrentQueue, execute: workItemFungeRoute!)
    }

    func go() {
//        print("dp go pre")
        Grid.shared.concurrentQueue.async(execute: workItemFunge!)
//        print("dp go post")
    }
}

extension Dispatch {
    func apoptosize() {
        currentTask = Apoptosize(scratch)
        currentTask.launch()
    }

    func colorize() {
//        print("pcolor")
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

    func fungeRoute() {
//        print("FR1 alive = \(scratch.isAlive), canSpawn = \(scratch.canSpawn)")
        if !scratch.isAlive { apoptosize(); return }
//        print("FR2")
        if !scratch.canSpawn { metabolize(); return }
//        print("FR3")
        wangkhi()
//        print("FR4")
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
