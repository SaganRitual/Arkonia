import SpriteKit

protocol HasXY {
    var x: Int { get }
    var y: Int { get }
}

extension GridCell {
    static func atIf(_ x: Int, _ y: Int) -> GridCell? {
        let p = AKPoint(x: x, y: y)
        if let c = Grid.cells[p] { return c }

        Log.L.write("atIf -> nil: (\(x), \(y))", level: 51)
        return nil
    }

    static func at(_ x: Int, _ y: Int) -> GridCell {
        let p = AKPoint(x: x, y: y)

        guard let g = Grid.cells[p] else { fatalError() }
        return g
    }

    static func atIf(_ position: AKPoint) -> GridCell? {
        return GridCell.atIf(position.x, position.y)
    }

    static func at(_ position: AKPoint) -> GridCell {
        return GridCell.at(position.x, position.y)
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

}
