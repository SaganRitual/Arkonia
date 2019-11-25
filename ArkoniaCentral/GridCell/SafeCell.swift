import SpriteKit

protocol SafeConnectorProtocol { }

class SafeCell: GridCellProtocol, SafeConnectorProtocol {
    let gridPosition: AKPoint
    let scenePosition: CGPoint
    let randomScenePosition: CGPoint?
    weak var sprite: SKSpriteNode?

    let contents: GridCell.Contents
    var iOwnTheGridCell: Bool { willSet { precondition(newValue == false) } }
    let ownerSignature: String
    var parasite: String?

    init(from original: GridCell, ownerSignature: String, takeOwnership: Bool = true) {
        self.gridPosition = original.gridPosition
        self.scenePosition = original.scenePosition
        self.randomScenePosition = original.randomScenePosition
        self.ownerSignature = ownerSignature
        self.contents = original.contents
        self.sprite = original.sprite

        self.iOwnTheGridCell = takeOwnership ?
            SafeCell.lockGridCellIf(ownerSignature, at: self.gridPosition) : false

        Log.L.write("SafeCell1 at \(gridPosition), requested by \(six(ownerSignature))/\(six(self.ownerSignature)), isLive = \(self.iOwnTheGridCell)", select: 7)
    }

    init(from original: GridCell, takeOwnership: Bool = true) {
        self.gridPosition = original.gridPosition
        self.scenePosition = original.scenePosition
        self.randomScenePosition = original.randomScenePosition
        self.ownerSignature = original.ownerName!
        self.contents = original.contents
        self.sprite = original.sprite

        self.iOwnTheGridCell = takeOwnership ?
            SafeCell.lockGridCellIf(original.ownerName!, at: self.gridPosition) : false

        Log.L.write("SafeCell2 at \(gridPosition), requested by \(six(self.ownerSignature)), isLive = \(self.iOwnTheGridCell)", select: 4)
    }

    init(
        from safeCopy: SafeCell,
        newContents: GridCell.Contents,
        newSprite: SKSpriteNode?,
        takeOwnership: Bool = true
    ) {
        self.gridPosition = safeCopy.gridPosition
        self.scenePosition = safeCopy.scenePosition
        self.randomScenePosition = safeCopy.randomScenePosition
        self.ownerSignature = safeCopy.ownerSignature
        self.contents = newContents
        self.sprite = newSprite

        self.iOwnTheGridCell = takeOwnership ?
            SafeCell.lockGridCellIf(safeCopy.ownerSignature, at: self.gridPosition) : false

        Log.L.write("SafeCell3a at \(gridPosition), requested by \(six(self.ownerSignature)), isLive = \(self.iOwnTheGridCell)", select: 4)
    }
    init(
        from safeCopy: SafeCell,
        takeOwnership: Bool = true
    ) {
        self.gridPosition = safeCopy.gridPosition
        self.scenePosition = safeCopy.scenePosition
        self.randomScenePosition = safeCopy.randomScenePosition
        self.ownerSignature = safeCopy.ownerSignature
        self.contents = safeCopy.contents
        self.sprite = safeCopy.sprite

        self.iOwnTheGridCell = takeOwnership ?
            SafeCell.lockGridCellIf(safeCopy.ownerSignature, at: self.gridPosition) : false

        Log.L.write("SafeCell3b at \(gridPosition), requested by \(six(self.ownerSignature)), isLive = \(self.iOwnTheGridCell)", select: 4)
    }

    init(from possiblyDeadCell: SafeCell) {
        self.gridPosition = possiblyDeadCell.gridPosition
        self.scenePosition = possiblyDeadCell.scenePosition
        self.randomScenePosition = possiblyDeadCell.randomScenePosition
        self.ownerSignature = possiblyDeadCell.ownerSignature
        self.contents = possiblyDeadCell.contents
        self.sprite = possiblyDeadCell.sprite
        self.iOwnTheGridCell = true

        Log.L.write("SafeCell3 at \(gridPosition), requested by \(six(self.ownerSignature)), isLive = \(self.iOwnTheGridCell)", select: 4)
    }

    private init(from stage: SafeStage) {
        self.gridPosition = stage.toCell.gridPosition
        self.scenePosition = stage.toCell.scenePosition
        self.randomScenePosition = stage.toCell.randomScenePosition
        self.ownerSignature = stage.toCell.ownerSignature

        self.contents = stage.toCell.contents
        self.sprite = stage.toCell.sprite

        self.iOwnTheGridCell = false

        Log.L.write("SafeCell4 at \(gridPosition), requested by \(six(self.ownerSignature)), isLive = \(self.iOwnTheGridCell)", select: 4)
    }

    deinit {
        if iOwnTheGridCell {
            Log.L.write("~SafeCell \(gridPosition) for \(six(ownerSignature))/\(six(self.parasite))", select: 5)
            SafeCell.unlockGridCell(self.ownerSignature, self.parasite, at: self.gridPosition)
        } else {
            Log.L.write("~SafeCell(dead) \(gridPosition) for \(six(ownerSignature))/\(six(self.parasite))", select: 5)
        }
    }

    static func releaseStage(_ stage: SafeStage) -> SafeCell? {
//        let myLandingCell = SafeCell(from: stage)
        let myLandingCell = makeLiveCellIf(from: stage.toCell)
        return myLandingCell
    }

    static func unlockGridCell(_ ownerSignature: String?, _ parasite: String?, at gridPosition: AKPoint) {
        let unsafeCell = GridCell.at(gridPosition)

        Log.L.write("unlock \(gridPosition) for \(six(ownerSignature)), actual \(six(unsafeCell.ownerName)), parasite \(six(parasite))", select: 9)
        assert(unsafeCell.ownerName == ownerSignature || unsafeCell.ownerName == parasite)

        unsafeCell.ownerName = nil
    }

    static func makeLiveCellIf(from possiblyDeadCell: SafeCell) -> SafeCell? {
        defer { possiblyDeadCell.iOwnTheGridCell = false }

        let sc = SafeCell(from: possiblyDeadCell)

        if Disengage.iOwnTheGridCell(possiblyDeadCell) == false {
            sc.iOwnTheGridCell = false
            return nil
        }

        return sc
    }

    static func lockGridCellIf(_ ownerSignature: String, at gridPosition: AKPoint) -> Bool {
        let unsafeCell = GridCell.at(gridPosition)
        var locked = false

        Log.L.write("lockGridCellIf \(gridPosition) for \(six(ownerSignature)) current \(six(unsafeCell.ownerName))", select: 9)
        if unsafeCell.ownerName == nil {
            unsafeCell.ownerName = ownerSignature
            locked = true
            Log.L.write("lock \(gridPosition) for \(ownerSignature)", select: 9)
        }

        Log.L.write("lockGridCellIf = \(locked) at \(gridPosition) held by \(six(unsafeCell.ownerName))", select: 9)
        return locked
    }
}

extension GridCell {
    func engage_(_ ownerName: String, _ require: Bool) -> SafeCell {
        let sc = SafeCell(from: self, ownerSignature: ownerName)

        if sc.iOwnTheGridCell == false && require == true { fatalError() }
        return sc
    }
}
