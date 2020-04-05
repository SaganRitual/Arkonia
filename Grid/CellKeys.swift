//swiftlint:disable unused_setter_value
import SpriteKit

protocol GridCellKey {
    var gridPosition: AKPoint { get }
    var manna: Manna? { get }
    var ownerName: ArkonName { get }
    var stepper: Stepper? { get }
}

struct ColdKey: GridCellKey {
    init(for cell: GridCell) {
        gridPosition = cell.gridPosition
        manna = cell.manna
        ownerName = cell.ownerName
        stepper = cell.stepper
    }

    let gridPosition : AKPoint
    let ownerName: ArkonName
    let manna: Manna?
    let stepper: Stepper?
}

class HotKey: GridCellKey, CustomDebugStringConvertible {
    private(set) weak var gridCell: GridCell?

    var debugDescription: String {
        "\(gridCell?.gridPosition ?? AKPoint(x: -4242, y: -4242))"
    }

    var gridPosition: AKPoint {
        get { return gridCell!.gridPosition }
        set { fatalError() }
    }

    var randomScenePosition: CGPoint? {
        get { return gridCell?.randomScenePosition }
        set { fatalError() }
    }

    var scenePosition: CGPoint {
        get { return gridCell?.scenePosition ?? CGPoint(x: -42.42, y: -42.42) }
        set { fatalError() }
    }

    var manna: Manna? {
        get { return gridCell?.manna }
    }

    var ownerName: ArkonName {
        get { return gridCell?.ownerName ?? ArkonName.empty }
        set { gridCell?.ownerName = newValue }
    }

    var stepper: Stepper? {
        get { return gridCell?.stepper }
    }

    init(for cell: GridCell, ownerName: ArkonName) {
        self.gridCell = cell
        cell.isLocked = true
        cell.ownerName = ownerName
        Debug.log(level: 85) { "HotKey at \(cell.gridPosition) for \(six(ownerName))" }

        cell.coldKey = ColdKey(for: cell)
    }

    deinit {
        // Releasing the HotKey involves the HotKey itself. So we have to tell
        // it to shut down before we reach deinit
        assert(gridCell == nil)
    }

    static var rescheduledCount = 0
    static func countRescheduledArkons(more: Bool) -> Int {
        DispatchQueue.global(qos: .utility).sync {
            rescheduledCount += more ? 1 : -1
            return rescheduledCount
        }
    }

    func reengageRequesters() {
        guard let c = gridCell else { return }

        Debug.log(level: 146) {
            return c.toReschedule.isEmpty ? nil :
            "Reengage from \(c.toReschedule.count) requesters at \(gridPosition)"
        }

        while let waitingStepper = c.getRescheduledArkon() {
            if let dp = waitingStepper.dispatch, let st = dp.scratch.stepper {
                let count = HotKey.countRescheduledArkons(more: false)
                let ch = dp.scratch
                assert(ch.engagerKey == nil)
                Debug.log(level: 157) { "reengageRequesters: \(count) \(six(st.name)) at \(self.gridPosition); from \(ch.cellShuttle?.fromCell?.gridPosition ?? AKPoint.zero), to \(ch.cellShuttle?.toCell?.gridPosition ?? AKPoint.zero)" }
                dp.disengage()
                return
            }
        }

        if c.mannaAwaitingRebloom {
            c.manna!.rebloom()
            c.mannaAwaitingRebloom = false
        }
    }

    func releaseLock(serviceRequesters: Bool = true) {
        gridCell?.releaseLock()
        if serviceRequesters { reengageRequesters() }
        gridCell = nil
    }

    func transferKey(to winner: Stepper, _ onComplete: @escaping () -> Void) {
        guard let c = gridCell else { fatalError() }
        precondition(c.isLocked)

        Debug.log(level: 71) { "transferKey from \(six(self.ownerName)) at \(gridPosition) to \(six(winner.name))" }

        self.ownerName = winner.name
        Debug.log(level: 104) { "setContents from transferKey in \(c.gridPosition)" }
        c.stepper = winner
        if winner.dispatch.scratch.engagerKey != nil { releaseLock() }
        Debug.log(level: 104) { "setContents from transferKey out \(c.gridPosition)" }
        onComplete()
    }
}

class NilKey: GridCellKey {
    //swiftlint:disable unused_setter_value
    var gridCell: GridCell? { get { nil } set { fatalError() } }
    var gridPosition: AKPoint { get { AKPoint(x: -4444, y: -4444) } set { fatalError() } }
    var manna: Manna?  { get { nil } set { fatalError() } }
    var ownerName: ArkonName { get { ArkonName.offgrid } set { fatalError() } }
    var stepper: Stepper?  { get { nil } set { fatalError() } }
    //swiftlint:enable unused_setter_value
}
