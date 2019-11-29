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

    var contents = Contents.nothing { didSet { previousContents = oldValue } }
    private(set) var previousContents = Contents.nothing
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

    func releaseLock(_ cellConnector: SafeCell) {
        Log.L.write("releaseLock", level: 27)

        defer { isLocked = false }
        commit(cellConnector)

        guard let st = cellConnector.sprite?.getStepper(require: false) else { return }
        guard let dp = st.dispatch else { return }
        let ch = dp.scratch
        if ch.isAwaitingWakeup == true {
            precondition(ch.isEngaged == false)

            ch.isAwaitingWakeup = false
            dp.engage()
        }
    }
}
