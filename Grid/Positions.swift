import SpriteKit

protocol HasXY {
    var x: Int { get }
    var y: Int { get }
}

extension GridCell {
    static func atIf(_ x: Int, _ y: Int) -> GridCell? {
        let p = AKPoint(x: x, y: y)
        return Grid.shared.getCellIf(at: p)
    }

    static func at(_ x: Int, _ y: Int) -> GridCell {
        let c = (atIf(x, y))!
        return c
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
