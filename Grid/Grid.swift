import Foundation

struct Grid {
    private static var theGrid: Grid!

    let arkons:  GridArkons
    let core:    GridCore
    let indexer: GridIndexer
    let manna:   GridManna
    let sync:    GridSync

    static var gridDimensionsCells: AKSize { theGrid.core.gridDimensionsCells }
    static var portalDimensionsPix: CGSize { theGrid.core.portalDimensionsPix }

    static func makeGrid(
        cellDimensionsPix: CGSize, portalDimensionsPix: CGSize,
        maxCSenseRings: Int, funkyCellsMultiplier: CGFloat?
    ) {
        theGrid = .init(
            cellDimensionsPix, portalDimensionsPix, maxCSenseRings,
            funkyCellsMultiplier
        )
    }

    private init(
        _ cellDimensionsPix: CGSize, _ portalDimensionsPix: CGSize,
        _ maxCSenseRings: Int, _ funkyCellsMultiplier: CGFloat?
    ) {
        self.indexer = .init(maxCSenseRings: maxCSenseRings)

        core = .init(
            cellDimensionsPix: cellDimensionsPix,
            portalDimensionsPix: portalDimensionsPix,
            maxCSenseRings: maxCSenseRings,
            funkyCellsMultiplier: funkyCellsMultiplier
        )

        arkons =  GridArkons()
        manna =   GridManna()
        sync =    GridSync()

        SensorPad.gridSync = sync
    }
}

extension Grid {
    static func asteroidize(_ virtualPosition: AKPoint) -> Int? {
        return theGrid.core.asteroidize(virtualPosition)
    }
}

extension Grid {
    static func plantManna(at absoluteIndex: Int) {
        theGrid.manna.plantManna(at: absoluteIndex)
    }
}

extension Grid {
    static func attachArkonToGrid(
        _ newborn: Stepper, _ onComplete: @escaping () -> Void
    ) {
        theGrid.sync.attachArkonToGrid(newborn, onComplete)
    }

    static func detachArkonFromGrid(at absoluteIndex: Int) {
        theGrid.sync.completeDeferredLockRequest(absoluteIndex)
    }
}

extension Grid {
    static func cellAt(_ absoluteIndex: Int) -> GridCell { theGrid.core.cellAt(absoluteIndex) }
    static func cellAt(_ gridPoint: AKPoint) -> GridCell { theGrid.core.cellAt(gridPoint) }
    static func mannaAt(_ absoluteIndex: Int) -> Manna? { theGrid.manna.mannaAt(absoluteIndex) }
    static func arkonAt(_ absoluteIndex: Int) -> Stepper? { theGrid.arkons.arkonAt(absoluteIndex) }
}

extension Grid {
    static func localIndexToVirtualGrid(center: AKPoint, localIx: Int) -> AKPoint {
        theGrid.indexer.localIndexToVirtualGrid(center, localIx)
    }
}

extension Grid {
    static func moveArkon(
        from sourceAbsoluteIndex: Int, toGridCell: GridCell
    ) {
        theGrid.arkons.moveArkon(from: sourceAbsoluteIndex, toGridCell: toGridCell)
    }

    static func placeNewborn(_ newborn: Stepper, at absoluteIndex: Int) {
        theGrid.arkons.placeNewborn(newborn, at: absoluteIndex)
    }
}

extension Grid {
    static func absoluteIndex(of point: AKPoint) -> Int {
        theGrid.core.absoluteIndex(of: point)
    }

    static func gridPosition(of index: Int) -> AKPoint {
        theGrid.core.gridPosition(of: index)
    }

    static func lockRandomCell(_ onComplete: @escaping (GridCell) -> Void) {
        theGrid.sync.lockRandomCell(onComplete)
    }

    static func randomCellIndex() -> Int {
        let cCellsInGrid = theGrid.core.gridDimensionsCells.area()
        return Int.random(in: 0..<cCellsInGrid)
    }

    static func randomCell() -> GridCell { cellAt(randomCellIndex()) }
}
