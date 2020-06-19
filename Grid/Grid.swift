import Foundation

struct Grid {
    static var shared: Grid!

    let arkons:  IngridArkons
    let core:    IngridCore
    let indexer: GridIndexer
    let manna:   IngridManna
    let sprites: IngridSprites
    let sync:    GridSync

    init(
        cellDimensionsPix: CGSize, portalDimensionsPix: CGSize,
        maxCSenseRings: Int, funkyCellsMultiplier: CGFloat?
    ) {
        self.indexer = .init(maxCSenseRings: maxCSenseRings)

        core = .init(
            cellDimensionsPix: cellDimensionsPix,
            portalDimensionsPix: portalDimensionsPix,
            maxCSenseRings: maxCSenseRings,
            funkyCellsMultiplier: funkyCellsMultiplier
        )

        let cCells = core.gridDimensionsCells.area()

        arkons =  IngridArkons(cCells)
        manna =   IngridManna(cCells)
        sprites = IngridSprites(cCells)
        sync =    GridSync(cCells)
    }
}

extension Grid {
    func cellAt(_ absoluteIndex: Int) -> GridCellConnector { core.cellAt(absoluteIndex) }

    func arkonAt(_ absoluteIndex: Int) -> Stepper? { arkons.arkonAt(absoluteIndex) }
    func mannaAt(_ absolutIndex: Int) -> Manna?    { manna.mannaAt(absolutIndex) }

    func moveArkon(
        _ stepper: Stepper, fromCell: GridCell, toCell: GridCell
    ) {
        arkons.moveArkon(fromCell: fromCell, toCell: toCell)
        sync.completeDeferredLockRequest(fromCell.absoluteIndex)
    }

    func placeArkon(_ stepper: Stepper, atIndex: Int) {
        arkons.placeArkonOnGrid(stepper, atIndex: atIndex)
    }

    func releaseArkon(_ stepper: Stepper) {
        let releasedCellIx = self.arkons.releaseArkon(stepper)
        sync.completeDeferredLockRequest(releasedCellIx)
    }
}

extension Grid {
    static func absoluteIndex(of point: AKPoint) -> Int {
        Grid.shared.core.absoluteIndex(of: point)
    }

    static func absolutePosition(of index: Int) -> AKPoint {
        Grid.shared.core.absolutePosition(of: index)
    }

    static func randomCellIndex() -> Int {
        let cCellsInGrid = Grid.shared.core.gridDimensionsCells.area()
        return Int.random(in: 0..<cCellsInGrid)
    }
}
