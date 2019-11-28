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

    init(from original: GridCell, owner: String, live: Bool = true) {
        self.gridPosition = original.gridPosition
        self.scenePosition = original.scenePosition
        self.randomScenePosition = original.randomScenePosition
//        print("so1")
        self.owner = owner

        self.contents = original.contents
        self.sprite = original.sprite

//        print("SafeCell1 at \(gridPosition), requested by \(six(owner))")

        if live {
            self.isLive = SafeCell.lockGridCellIf(self.owner!, at: self.gridPosition)
        }
    }

    init(from original: GridCell, live: Bool = true) {
        self.gridPosition = original.gridPosition
        self.scenePosition = original.scenePosition
        self.randomScenePosition = original.randomScenePosition
//        print("so1")
        self.owner = original.owner

        self.contents = original.contents
        self.sprite = original.sprite

//        print("SafeCell1 at \(gridPosition), requested by \(six(owner))")

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
//        print("so2")
        self.owner = safeCopy.owner

        self.contents = newContents
        self.sprite = newSprite

//        print("SafeCell2 at \(gridPosition), requested by \(six(owner))")

        if live {
            self.isLive = SafeCell.lockGridCellIf(self.owner!, at: self.gridPosition)
        }
    }

    deinit {
        if isLive {
//            print("~SafeCell \(gridPosition) for \(owner ?? "no owner?")")
            SafeCell.unlockGridCell(self.owner!, at: self.gridPosition)
        } else {
//            print("~SafeCell(dead) \(gridPosition) for \(owner ?? "no owner?")")
        }
    }

    static func unlockGridCell(_ owner: String, at gridPosition: AKPoint) {
        let unsafeCell = GridCell.at(gridPosition)

//        print("0unlockGridCell \(gridPosition) for \(six(unsafeCell.owner))")
        assert(unsafeCell.owner == owner)

//        print("so3")
        unsafeCell.owner = nil
//        print("1unlockGridCellIf \(gridPosition) for \(six(unsafeCell.owner))")
    }

    static func lockGridCellIf(_ owner: String, at gridPosition: AKPoint) -> Bool {
        let unsafeCell = GridCell.at(gridPosition)
        var locked = false

//        print("lockGridCellIf \(gridPosition) for \(six(owner)) current \(six(unsafeCell.owner))")
        if unsafeCell.owner == nil {
//            print("so4")
            unsafeCell.owner = owner
            locked = true
        }

//        print("lockGridCellIf = \(locked) at \(gridPosition) held by \(six(unsafeCell.owner))")
        return locked
    }
}

class SafeSenseGrid: SafeConnectorProtocol {
    let cells: [SafeCell?]

    init(from center: SafeCell, by cGridlets: Int) {
        guard let co = center.owner else { fatalError() }

        cells = [center] + (1..<cGridlets).map {
            let position = center.getGridPointByIndex($0, absolute: true)

            guard let unsafeCell = GridCell.atIf(position) else { return nil }
            return SafeCell(from: unsafeCell, owner: co)
        }
    }

    deinit {
//        print("~SafeSenseGrid")
    }
}

extension GridCell {

    func wiEngage(
        owner: String, require: Bool, onLock: ((SafeCell?) -> Void)?
    ) -> DispatchWorkItem {

        return DispatchWorkItem(flags: .barrier) {
            let cell = self.engage_(owner, require)
//            print("wiEngage \(cell?.gridPosition ?? AKPoint.zero) for \(owner)")
            onLock?(cell)
        }
    }

    func engage_(_ owner: String, _ require: Bool) -> SafeCell? {
        if self.owner == nil {
//            print("so6")
            return SafeCell(from: self, owner: owner)
        }

        if require { fatalError() }

        return nil
    }

    func extend(
        owner: String, from center: SafeCell, by cGridlets: Int, onLock: ((SafeSenseGrid?) -> Void)?
    ) -> DispatchWorkItem {
//        print("extend0 \(six(self.owner))")

        return DispatchWorkItem(flags: .barrier) {
//            print("extend1 \(six(owner))")
            let sc = SafeSenseGrid(from: center, by: cGridlets)
//            print("extend2 \(six(self.owner))")
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
//        print("SafeStage \(from.gridPosition), \(from.contents), \(six(from.sprite?.name)), \(to.gridPosition), \(to.contents), \(six(to.sprite?.name)), \(willMove)")
    }

    deinit {
//        print("~SafeStage")
        guard fromForCommit == nil, toForCommit == nil else {
//            print("committing changes")
            commit()
//            print("committed changes")
            return
        }
    }

    func commit() {
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

    func move() {
        guard fromForCommit == nil && toForCommit == nil else { fatalError() }
        if !willMove { return }

//        print("will move \(from.gridPosition), \(to.gridPosition)")

        fromForCommit = SafeCell(from: from, newContents: .nothing, newSprite: nil, live: false)
        toForCommit = SafeCell(from: to, newContents: from.contents, newSprite: from.sprite, live: false)
    }
}
