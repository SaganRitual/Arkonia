import SpriteKit

protocol SafeConnectorProtocol { }

class SafeCell: GridCellProtocol, SafeConnectorProtocol {
    let gridPosition: AKPoint
    var isLive = false
    let scenePosition: CGPoint
    let randomScenePosition: CGPoint?
    weak var sprite: SKSpriteNode?

    let contents: GridCell.Contents
    let ownerName: String?
    var parasite: String?

    init(from original: GridCell, ownerName: String, live: Bool = true) {
        self.gridPosition = original.gridPosition
        self.scenePosition = original.scenePosition
        self.randomScenePosition = original.randomScenePosition
//        Log.L.write("so1")
        self.ownerName = ownerName

        self.contents = original.contents
        self.sprite = original.sprite

        if live {
            self.isLive = SafeCell.lockGridCellIf(self.ownerName!, at: self.gridPosition)
        }

        Log.L.write("SafeCell1 at \(gridPosition), requested by \(six(ownerName))/\(six(self.ownerName)), isLive = \(self.isLive)", select: 4)
    }

    init(from original: GridCell, live: Bool = true) {
        self.gridPosition = original.gridPosition
        self.scenePosition = original.scenePosition
        self.randomScenePosition = original.randomScenePosition
        self.ownerName = original.ownerName

        self.contents = original.contents
        self.sprite = original.sprite

        if live {
            self.isLive = SafeCell.lockGridCellIf(self.ownerName!, at: self.gridPosition)
        }

        Log.L.write("SafeCell2 at \(gridPosition), requested by \(six(self.ownerName)), isLive = \(self.isLive)", select: 4)
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
        self.ownerName = safeCopy.ownerName

        self.contents = newContents
        self.sprite = newSprite

        if live {
            self.isLive = SafeCell.lockGridCellIf(self.ownerName!, at: self.gridPosition)
        }

        Log.L.write("SafeCell3 at \(gridPosition), requested by \(six(self.ownerName)), isLive = \(self.isLive)", select: 4)
    }

    static func releaseStage(_ stage: SafeStage) -> SafeCell {
        let myLandingCell = SafeCell(from: stage)
        transferCellLock(from: stage.to, to: myLandingCell)
        return myLandingCell
    }

    private init(from stage: SafeStage) {
        self.gridPosition = stage.to.gridPosition
        self.scenePosition = stage.to.scenePosition
        self.randomScenePosition = stage.to.randomScenePosition
        self.ownerName = stage.to.ownerName

        self.contents = stage.to.contents
        self.sprite = stage.to.sprite

        self.isLive = false

        Log.L.write("SafeCell4 at \(gridPosition), requested by \(six(self.ownerName)), isLive = \(self.isLive)", select: 4)
    }

    deinit {
        if isLive {
            Log.L.write("~SafeCell \(gridPosition) for \(six(ownerName))/\(six(self.parasite))", select: 4)
            SafeCell.unlockGridCell(self.ownerName, self.parasite, at: self.gridPosition)
        } else {
            Log.L.write("~SafeCell(dead) \(gridPosition) for \(six(ownerName))/\(six(self.parasite))", select: 4)
        }
    }

    static func unlockGridCell(_ owner: String?, _ parasite: String?, at gridPosition: AKPoint) {
        let unsafeCell = GridCell.at(gridPosition)

        assert(unsafeCell.ownerName == owner || unsafeCell.ownerName == parasite)

        Log.L.write("unlock \(gridPosition) for \(six(owner)), actual \(six(unsafeCell.ownerName)), parasite \(six(parasite))", select: 4)
        unsafeCell.ownerName = nil
    }

    static func transferCellLock(from oldOwner: SafeCell, to newOwner: SafeCell) {
        precondition(oldOwner.ownerName != nil)

        oldOwner.isLive = false

        if oldOwner != newOwner { newOwner.isLive = true }

        Log.L.write("transferCellLock from \(oldOwner.gridPosition) for \(six(oldOwner.ownerName)), to actual \(six(newOwner.ownerName))", select: 4)
    }

    static func lockGridCellIf(_ ownerName: String, at gridPosition: AKPoint) -> Bool {
        let unsafeCell = GridCell.at(gridPosition)
        var locked = false

        Log.L.write("lockGridCellIf \(gridPosition) for \(six(ownerName)) current \(six(unsafeCell.ownerName))", select: 4)
        if unsafeCell.ownerName == nil {
            unsafeCell.ownerName = ownerName
            locked = true
            Log.L.write("lock \(gridPosition) for \(ownerName)", select: 4)
        }

        Log.L.write("lockGridCellIf = \(locked) at \(gridPosition) held by \(six(unsafeCell.ownerName))", select: 4)
        return locked
    }
}

class SafeSenseGrid: SafeConnectorProtocol {
    let cells: [SafeCell?]

    init(from center: SafeCell, by cGridlets: Int) {
        guard let co = center.ownerName else { fatalError() }

        cells = [center] + (1..<cGridlets).map {
            let position = center.getGridPointByIndex($0, absolute: true)

            guard let unsafeCell = GridCell.atIf(position), unsafeCell.contents != .arkon else { return nil }
            return SafeCell(from: unsafeCell, ownerName: co)
        }
    }

    deinit {
        let center = cells[0]?.gridPosition
        let ownerName = cells[0]?.parasite ?? cells[0]?.ownerName
        Log.L.write("~SafeSenseGrid centered at \(center!) for \(six(ownerName))")
    }
}

extension GridCell {

    func engage_(_ ownerName: String, _ require: Bool) -> SafeCell? {
        if self.ownerName == nil { return SafeCell(from: self, ownerName: ownerName) }
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
        Log.L.write("SafeStage \(from.gridPosition), \(from.contents), \(six(from.ownerName)), \(to.gridPosition), \(to.contents), \(six(to.ownerName)), \(willMove)")
    }

    deinit {
        Log.L.write("~SafeStage \(six(from.ownerName)), \(six(to.ownerName))")
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
            newFrom.ownerName = f.parasite ?? f.ownerName
            Log.L.write("newFrom \(newFrom.contents), \(six(newFrom.ownerName)) (\(six(f.parasite)))")
        }

        let newTo = GridCell.at(t)
        newTo.contents = t.contents
        newTo.sprite = t.sprite
//        newTo.ownerName = t.parasite ?? t.ownerName
        Log.L.write("newTo \(newTo.contents), \(six(newTo.ownerName)) (\(six(t.parasite)))")

        fromForCommit = nil
        toForCommit = nil
    }

    func move() {
        guard fromForCommit == nil && toForCommit == nil else { fatalError() }
        if !willMove { return }

        Log.L.write("will move from \(six(from.ownerName)) \(from.gridPosition) to \(six(to.ownerName)) \(to.gridPosition)")

        fromForCommit = SafeCell(from: from, newContents: .nothing, newSprite: nil, live: false)
        toForCommit = SafeCell(from: to, newContents: from.contents, newSprite: from.sprite, live: false)
    }
}
