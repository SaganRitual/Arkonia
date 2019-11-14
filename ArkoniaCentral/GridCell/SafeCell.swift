import SpriteKit

protocol SafeConnectorProtocol { }

class SafeCell: GridCellProtocol, SafeConnectorProtocol {
    let gridPosition: AKPoint
    var isLive = true
    let scenePosition: CGPoint
    let randomScenePosition: CGPoint?
    weak var sprite: SKSpriteNode?

    let contents: GridCell.Contents
    let owner: String?

    init(from original: GridCell, live: Bool = true) {
        self.isLive = live

        self.gridPosition = original.gridPosition
        self.scenePosition = original.scenePosition
        self.randomScenePosition = original.randomScenePosition
        self.owner = original.owner

        self.contents = original.contents
        self.sprite = original.sprite

        if live { SafeCell.lockGridCellIf(self.owner!, at: self.gridPosition) }
    }

    init(
        from safeCopy: SafeCell,
        newContents: GridCell.Contents,
        newSprite: SKSpriteNode?,
        live: Bool = true
    ) {
        self.isLive = live

        self.gridPosition = safeCopy.gridPosition
        self.scenePosition = safeCopy.scenePosition
        self.randomScenePosition = safeCopy.randomScenePosition
        self.owner = safeCopy.owner

        self.contents = newContents
        self.sprite = newSprite

        if live { SafeCell.lockGridCellIf(self.owner!, at: self.gridPosition) }
    }

    deinit {
        if isLive {
//            print("~SafeCell")
            SafeCell.unlockGridCellIf(self.owner!, at: self.gridPosition) }
    }

    static func unlockGridCellIf(_ owner: String, at gridPosition: AKPoint) {
        let unsafeCell = GridCell.at(gridPosition)

        if unsafeCell.owner == owner { unsafeCell.owner = nil }
    }

    static func lockGridCellIf(_ owner: String, at gridPosition: AKPoint) {
        let unsafeCell = GridCell.at(gridPosition)

        if unsafeCell.owner == nil { unsafeCell.owner = owner }
    }
}

class SafeSenseGrid: SafeConnectorProtocol {
    let cells: [SafeCell?]

    init(from center: SafeCell, by cGridlets: Int) {
        guard let co = center.owner else { fatalError() }

        cells = [center] + (1..<cGridlets).map {
            let position = center.getGridPointByIndex($0, absolute: true)

            guard let unsafeCell = GridCell.atIf(position) else { return nil }

            if unsafeCell.owner == nil { unsafeCell.owner = co }

            return SafeCell(from: unsafeCell)
        }
    }

    deinit {
//        print("~SafeSenseGrid")
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
//            print("extend1 \(six(owner))")
            let sc = SafeSenseGrid(from: center, by: cGridlets)
//            print("extend2 \(six(owner))")
            return sc
        }
    }

    func stage(_ grid: SafeSenseGrid, _ combatant2: SafeCell) -> SafeStage? {
        return Grid.shared.serialQueue.sync {
            let sc = SafeStage(grid.cells[0]!, combatant2)
            return sc
        }
    }
}

class SafeStage: SafeConnectorProtocol {
    let willMove: Bool
    let from: SafeCell
    var fromForCommit: SafeCell?
    let to: SafeCell
    var toForCommit: SafeCell?

    init(_ from: SafeCell, _ to: SafeCell) {
        self.from = from; self.to = to; willMove = (from != to)
//        print("SafeStage \(from.gridPosition), \(from.contents), \(six(from.sprite?.name)), \(to.gridPosition), \(to.contents), \(six(to.sprite?.name)), \(willMove)")
    }

    deinit {
//        print("~SafeStage")
        guard fromForCommit == nil, toForCommit == nil else {
//            print("committing changes")
            commit()
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
        if !willMove { return }

//        print("will move \(from.gridPosition), \(to.gridPosition)")

        fromForCommit = SafeCell(from: from, newContents: .nothing, newSprite: nil, live: false)
        toForCommit = SafeCell(from: to, newContents: from.contents, newSprite: from.sprite, live: false)
    }
}
