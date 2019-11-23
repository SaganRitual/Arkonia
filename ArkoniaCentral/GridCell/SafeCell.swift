import SpriteKit

protocol SafeConnectorProtocol { }

class SafeCell: GridCellProtocol, SafeConnectorProtocol {
    let gridPosition: AKPoint
    var isLive = false
    let scenePosition: CGPoint
    let randomScenePosition: CGPoint?
    weak var sprite: SKSpriteNode?

    let contents: GridCell.Contents
    let owner: String?
    var parasite: String?

    init(from original: GridCell, owner: String, live: Bool = true) {
        self.gridPosition = original.gridPosition
        self.scenePosition = original.scenePosition
        self.randomScenePosition = original.randomScenePosition
//        Log.L.write("so1")
        self.owner = owner

        self.contents = original.contents
        self.sprite = original.sprite

//        Log.L.write("SafeCell1 at \(gridPosition), requested by \(six(owner))")

        if live {
            self.isLive = SafeCell.lockGridCellIf(self.owner!, at: self.gridPosition)
        }
    }

    init(from original: GridCell, live: Bool = true) {
        self.gridPosition = original.gridPosition
        self.scenePosition = original.scenePosition
        self.randomScenePosition = original.randomScenePosition
//        Log.L.write("so1")
        self.owner = original.owner

        self.contents = original.contents
        self.sprite = original.sprite

//        Log.L.write("SafeCell1 at \(gridPosition), requested by \(six(owner))")

        if live {
            self.isLive = SafeCell.lockGridCellIf(self.owner!, at: self.gridPosition)
        }
    }

    init(
        from safeCopy: SafeCell,
        newContents: GridCell.Contents,
        newSprite: SKSpriteNode?,
        live: Bool = true
    ) {
        self.gridPosition = safeCopy.gridPosition
        self.scenePosition = safeCopy.scenePosition
        self.randomScenePosition = safeCopy.randomScenePosition
//        Log.L.write("so2")
        self.owner = safeCopy.owner

        self.contents = newContents
        self.sprite = newSprite

//        Log.L.write("SafeCell2 at \(gridPosition), requested by \(six(owner))")

        if live {
            self.isLive = SafeCell.lockGridCellIf(self.owner!, at: self.gridPosition)
        }
    }

    static func collapseStage(_ stage: SafeStage) -> SafeCell {
        let myCell = SafeCell(from: stage)
        transferCellLock(from: stage.to, to: myCell)
    }

    private init(from stage: SafeStage) {
        self.gridPosition = stage.to.gridPosition
        self.scenePosition = stage.to.scenePosition
        self.randomScenePosition = stage.to.randomScenePosition
        self.owner = stage.to.owner

        self.contents = stage.to.contents
        self.sprite = stage.to.sprite

        self.isLive = false
    }

    deinit {
        if isLive {
            SafeCell.unlockGridCell(self.owner, self.parasite, at: self.gridPosition)
        } else {
            Log.L.write("~SafeCell(dead) \(gridPosition) for \(six(owner))/\(six(self.parasite))")
        }
    }

    static func unlockGridCell(_ owner: String?, _ parasite: String?, at gridPosition: AKPoint) {
        let unsafeCell = GridCell.at(gridPosition)

        assert(unsafeCell.owner == owner || unsafeCell.owner == parasite)

        Log.L.write("unlock \(gridPosition) for \(six(owner)), actual \(six(unsafeCell.owner)), parasite \(six(parasite))", select: 1)
        unsafeCell.owner = nil
    }

    static func transferCellLock(from oldOwner: SafeCell, to newOwner: SafeCell) {
        precondition(oldOwner.owner != nil)
        oldOwner.isLive = false
        newOwner.isLive = true
    }

    static func lockGridCellIf(_ owner: String, at gridPosition: AKPoint) -> Bool {
        let unsafeCell = GridCell.at(gridPosition)
        var locked = false

//        Log.L.write("lockGridCellIf \(gridPosition) for \(six(owner)) current \(six(unsafeCell.owner))")
        if unsafeCell.owner == nil {
            unsafeCell.owner = owner
            locked = true
            Log.L.write("lock \(gridPosition) for \(owner)", select: 1)
        }

//        Log.L.write("lockGridCellIf = \(locked) at \(gridPosition) held by \(six(unsafeCell.owner))")
        return locked
    }
}

class SafeSenseGrid: SafeConnectorProtocol {
    let cells: [SafeCell?]

    init(from center: SafeCell, by cGridlets: Int) {
        guard let co = center.owner else { fatalError() }

        cells = [center] + (1..<cGridlets).map {
            let position = center.getGridPointByIndex($0, absolute: true)

            guard let unsafeCell = GridCell.atIf(position), unsafeCell.contents != .arkon else { return nil }
            return SafeCell(from: unsafeCell, owner: co)
        }
    }

    deinit {
        let center = cells[0]?.gridPosition
        let owner = cells[0]?.parasite ?? cells[0]?.owner
        Log.L.write("~SafeSenseGrid centered at \(center!) for \(six(owner))")
    }
}

extension GridCell {

    func engage_(_ owner: String, _ require: Bool) -> SafeCell? {
        if self.owner == nil { return SafeCell(from: self, owner: owner) }
        if require { fatalError() }
        return nil
    }

    func extend(
        owner: String, from center: SafeCell, by cGridlets: Int, onLock: ((SafeSenseGrid?) -> Void)?
    ) -> DispatchWorkItem {
        return DispatchWorkItem(flags: .barrier) {
            let sc = SafeSenseGrid(from: center, by: cGridlets)
            onLock?(sc)
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
        Log.L.write("SafeStage \(from.gridPosition), \(from.contents), \(six(from.owner)), \(to.gridPosition), \(to.contents), \(six(to.owner)), \(willMove)")
    }

    deinit {
        Log.L.write("~SafeStage \(six(from.owner)), \(six(to.owner))")
        guard fromForCommit == nil && toForCommit == nil else {
            Log.L.write("committing changes")
            commit()
            Log.L.write("committed changes")
            return
        }
    }

    func commit() {
        guard let f = fromForCommit, let t = toForCommit else { return }

        if f != t {
            let newFrom = GridCell.at(f)
            newFrom.contents = f.contents
            newFrom.sprite = f.sprite
            newFrom.owner = f.parasite ?? f.owner
            Log.L.write("newFrom \(newFrom.contents), \(six(newFrom.owner)) (\(six(f.parasite)))")
        }

        let newTo = GridCell.at(t)
        newTo.contents = t.contents
        newTo.sprite = t.sprite
        newTo.owner = t.parasite ?? t.owner
        Log.L.write("newTo \(newTo.contents), \(six(newTo.owner)) (\(six(t.parasite)))")

        fromForCommit = nil
        toForCommit = nil
    }

    func move() {
        guard fromForCommit == nil && toForCommit == nil else { fatalError() }
        if !willMove { return }

        Log.L.write("will move from \(six(from.owner)) \(from.gridPosition) to \(six(to.owner)) \(to.gridPosition)")

        fromForCommit = SafeCell(from: from, newContents: .nothing, newSprite: nil, live: false)
        toForCommit = SafeCell(from: to, newContents: from.contents, newSprite: from.sprite, live: false)
    }
}
