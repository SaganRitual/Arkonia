import SpriteKit

protocol SafeConnectorProtocol {
}

class SafeCell: GridCellProtocol, SafeConnectorProtocol {
    let gridPosition: AKPoint
    let scenePosition: CGPoint
    let randomScenePosition: CGPoint?
    weak var sprite: SKSpriteNode?

    let contents: GridCell.Contents
    let owner: String?

    init(from original: GridCell) {
        self.gridPosition = original.gridPosition
        self.scenePosition = original.scenePosition
        self.randomScenePosition = original.randomScenePosition
        self.owner = original.owner

        self.contents = original.contents
        self.sprite = original.sprite

        SafeCell.setOwner(self.owner!, at: self.gridPosition)
    }

    init(from safeCopy: SafeCell, newContents: GridCell.Contents, newSprite: SKSpriteNode?) {
        self.gridPosition = safeCopy.gridPosition
        self.scenePosition = safeCopy.scenePosition
        self.randomScenePosition = safeCopy.randomScenePosition
        self.owner = safeCopy.owner

        self.contents = newContents
        self.sprite = newSprite

        SafeCell.setOwner(self.owner!, at: self.gridPosition)
    }

    static func setOwner(_ owner: String, at gridPosition: AKPoint) {
        let unsafeCell = GridCell.at(gridPosition)

        if unsafeCell.owner == nil { unsafeCell.owner = owner }
    }
}

class SafeSenseGrid: SafeConnectorProtocol {
    let cells: [SafeCell]

    init(from center: SafeCell, by cGridlets: Int) {
        guard let co = center.owner else { fatalError() }

        cells = [center] + (1..<cGridlets).map {
            let position = center.getGridPointByIndex($0, absolute: true)
            let unsafeCell = GridCell.at(position)

            if unsafeCell.owner == nil { unsafeCell.owner = co }

            return SafeCell(from: unsafeCell)
        }
    }
}

extension GridCell {

    func engage(owner: String, require: Bool) -> SafeCell? {
        var sc: SafeCell?

        Grid.shared.serialQueue.sync {
            if self.owner == nil {
                self.owner = owner
                sc = SafeCell(from: self)
                return
            }

            if require { fatalError() }
        }

        return sc
    }

    func extend(owner: String, from center: SafeCell, by cGridlets: Int) -> SafeSenseGrid? {
        return Grid.shared.serialQueue.sync {
            let sc = SafeSenseGrid(from: center, by: cGridlets)
            return sc
        }
    }

    func stage(_ grid: SafeSenseGrid, _ combatant2: SafeCell) -> SafeStage? {
        return Grid.shared.serialQueue.sync {
            let sc = SafeStage(grid.cells[0], combatant2)
            return sc
        }
    }
}

class SafeStage: SafeConnectorProtocol {
    var willMove = false
    let from: SafeCell
    var fromForCommit: SafeCell?
    let to: SafeCell
    var toForCommit: SafeCell?

    init(_ from: SafeCell, _ to: SafeCell) {
        self.from = from; self.to = to
    }

    deinit {
        guard fromForCommit == nil, toForCommit == nil else {
            print("uncommitted changes")
            return
        }
    }

    func commit() {
        Grid.shared.serialQueue.sync {
            guard let f = fromForCommit, let t = toForCommit else { return }

            let newFrom = GridCell.at(f)
            newFrom.contents = f.contents
            newFrom.sprite = f.sprite

            let newTo = GridCell.at(t)
            newTo.contents = t.contents
            newTo.sprite = t.sprite

            fromForCommit = nil
            toForCommit = nil
        }
    }

    func move() {
        guard fromForCommit == nil && toForCommit == nil else { fatalError() }
        if from == to { return }

        willMove = true
        fromForCommit = SafeCell(from: from, newContents: .nothing, newSprite: nil)
        toForCommit = SafeCell(from: to, newContents: from.contents, newSprite: from.sprite)
    }
}
