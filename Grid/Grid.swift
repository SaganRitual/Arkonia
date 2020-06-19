import Foundation

struct Grid {
    static var shared: Grid!

    let arkons:  GridArkons
    let core:    GridCore
    let indexer: GridIndexer
    let manna:   GridManna
    let sprites: GridDebugView
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

        arkons =  GridArkons(cCells)
        manna =   GridManna(cCells)
        sprites = GridDebugView(cCells)
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
        arkons.moveArkon(stepper, from: fromCell.absoluteIndex, to: toCell.absoluteIndex)
        sync.completeDeferredLockRequest(fromCell.absoluteIndex)
    }

    func placeArkon(_ stepper: Stepper, atIndex: Int) {
        arkons.placeArkon(stepper, atIndex: atIndex)
    }

    func removeArkon(_ stepper: Stepper) {
        let releasedCellIx = arkons.removeArkon(stepper)
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
