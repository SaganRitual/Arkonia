import SpriteKit

class GridCell: GridCellProtocol, Equatable, CustomDebugStringConvertible {
    enum Contents: Double, CaseIterable {
        case arkon, invalid, manna, nothing

        func isEdible() -> Bool {
            return self == .arkon || self == .manna
        }

        func isOccupied() -> Bool {
            return self == .arkon || self == .manna
        }
    }

    var debugDescription: String { return "GridCell.at(\(gridPosition.x), \(gridPosition.y))" }

    weak var cellConnector: SafeCell?
    let gridPosition: AKPoint
    var isLocked = false
    var randomScenePosition: CGPoint?
    let scenePosition: CGPoint

    var contents = Contents.nothing
    weak var sprite: SKSpriteNode?

    init(gridPosition: AKPoint, scenePosition: CGPoint) {
        self.gridPosition = gridPosition
        self.scenePosition = scenePosition
    }
}

extension GridCell {
    private func commit(_ cellConnector: SafeCell) {
        contents = cellConnector.contents
        sprite = cellConnector.sprite
    }

    @discardableResult
    func lock(require: Bool = true) -> GridCell? {
        defer { isLocked = true }

        if isLocked {
            Log.L.write("GridCell: not locked; return nil", level: 27)
            precondition(require == false)
            return nil
        }

        Log.L.write("GridCell: locked; return self", level: 27)
        return self
    }

    static var cRl = 0
    func releaseLock(_ cellConnector: SafeCell) {
        GridCell.cRl += 1
        defer { isLocked = false }
        commit(cellConnector)

        guard let st = cellConnector.sprite?.getStepper(require: false) else {
            if(cellConnector.contents == .arkon) {
                Log.L.write("arkon already freed \(GridCell.cRl); sprite \(six(cellConnector.sprite?.name)) = ", level: 32)
            }
            return
        }

        guard let dp = st.dispatch else {
            Log.L.write("no dispatch \(GridCell.cRl) \(six(st.name))", level: 32)
            return
        }

        let ch = dp.scratch
        if ch.isAwaitingWakeup == true {
            st.nose.color = .yellow
            Log.L.write("GridCell wakeup waiter \(six(st.name)) \(GridCell.cRl)", level: 32)
            precondition(ch.isEngaged == false)

            ch.isAwaitingWakeup = false
            dp.engage()
        }
    }
}
