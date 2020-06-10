import Foundation

let grid = Ingrid(
    cellDimensionsPix: CGSize(width: 100, height: 100),
    portalDimensionsPix: CGSize(width: 1500, height: 1300),
    maxCSenseRings: 1, funkyCellsMultiplier: nil
)

let theDispatch = DispatchQueue(label: "theDispatch", target: DispatchQueue.global())
let wait = DispatchSemaphore(value: 0)

struct Arkon {
    let cCellsInRange = 9
    var engagerSpec: EngagerSpec?
    let name: String
    var pad: UnsafeMutablePointer<IngridCellDescriptor>

    init(_ name: String) {
        self.name = name
        pad = .allocate(capacity: cCellsInRange)
        pad.initialize(repeating: IngridCellDescriptor(), count: cCellsInRange)
    }

    mutating func goArkon(at center: AKPoint, _ onComplete: @escaping () -> Void) {

        self.engagerSpec = EngagerSpec(
            cCellsInRange: cCellsInRange, center: center, onComplete: onComplete, pad: self.pad
        )

        grid.engageSensorPad(engagerSpec!)
    }

    func stopArkon(keepTheseCells: [Int] = [], _ onComplete: @escaping () -> Void) {
        grid.disengageSensorPad(pad: pad, padCCells: cCellsInRange, keepTheseCells: keepTheseCells, onComplete)
    }
}

var a = Arkon("a")
a.goArkon(at: AKPoint.zero) {
    Debug.log { "Arkon a fulfilled" }
    let four = a.pad[4].absoluteIndex
    let eight = a.pad[8].absoluteIndex
    a.stopArkon(keepTheseCells: [eight, four]) {
        a.stopArkon(keepTheseCells: [eight]) {
            a.stopArkon(keepTheseCells: [], {})
        }
    }
}

var b = Arkon("b")
b.goArkon(at: AKPoint.zero + 1) {
    Debug.log { "Arkon b fulfilled" }
    b.stopArkon(keepTheseCells: [], {})
}

var c = Arkon("c")
c.goArkon(at: AKPoint(x: -5, y: -5)) {
    Debug.log { "Arkon c fulfilled" }
    c.stopArkon(keepTheseCells: [], {})
}

var d = Arkon("d")
d.goArkon(at: AKPoint.zero - 1) {
    Debug.log { "Arkon d fulfilled" }
    d.stopArkon(keepTheseCells: [], {})
    wait.signal()
}

wait.wait()
Debug.waitForLogToClear()
