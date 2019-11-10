import SpriteKit

protocol HasXY {
    var x: Int { get }
    var y: Int { get }
}

extension GridCell {
    static func atIf(_ x: Int, _ y: Int) -> GridCell? {
        let p = AKPoint(x: x, y: y)
        return Grid.cells[p]
    }

    static func at(_ x: Int, _ y: Int) -> GridCell {
        let p = AKPoint(x: x, y: y)

        guard let g = Grid.cells[p] else { fatalError() }
        return g
    }

    static func at(_ safeCell: SafeCell) -> GridCell {
        return GridCell.at(safeCell.gridPosition)
    }

    static func atIf(_ position: AKPoint) -> GridCell? {
        return GridCell.atIf(position.x, position.y)
    }

    static func at(_ position: AKPoint) -> GridCell {
        return GridCell.at(position.x, position.y)
    }

    static func atIf(_ copy: SafeCell) -> GridCell? {
        return atIf(copy.gridPosition)
    }

    static func constrainToGrid(_ x: Int, _ y: Int) -> (Int, Int) {
        let cx = Grid.dimensions.wGrid - 1
        let cy = Grid.dimensions.hGrid - 1

        let constrainedX = min(cx, max(-cx, x))
        let constrainedY = min(cy, max(-cy, y))

        return (constrainedX, constrainedY)
    }

    static func isOnGrid(_ x: Int, _ y: Int) -> Bool {
        let (cx, cy) = constrainToGrid(x, y)
        return cx == x && cy == y
    }

    static func isOnGrid(_ xy: HasXY) -> Bool {
        return isOnGrid(xy.x, xy.y)
    }

    static func + (_ lhs: GridCell, _ rhs: GridCell) -> GridCell {
        return GridCell.at(lhs.gridPosition + rhs.gridPosition)
    }

    static func + (_ lhs: GridCell, _ rhs: AKPoint) -> GridCell {
        return GridCell.at(lhs.gridPosition + rhs)
    }

    static func - (_ lhs: GridCell, _ rhs: AKPoint) -> GridCell {
        return GridCell.at(lhs.gridPosition - rhs)
    }

    static func == (_ lhs: GridCell, _ rhs: GridCell) -> Bool {
        return lhs === rhs
    }

    static func === (_ lhs: GridCell, _ rhs: SafeCell) -> Bool {
        guard let r = GridCell.atIf(rhs) else { fatalError() }
        return lhs === r
    }

}

extension SafeCell {
    static func == (_ lhs: SafeCell, _ rhs: SafeCell) -> Bool {
        return lhs.gridPosition == rhs.gridPosition
    }
}
