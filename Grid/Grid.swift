import Foundation

struct Grid {
    private static var theGrid: Grid!

    let core:    GridCore
    let indexer: GridIndexer
    let manna:   GridManna

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

        manna =   GridManna()
    }
}

extension Grid {
    static func plantManna(at absoluteIndex: Int) -> Manna {
        return theGrid.manna.plantManna(at: absoluteIndex)
    }
}

extension Grid {
    static func cellAt(_ localIx: Int, from centerGridCell: GridCell) -> (GridCell, AKPoint) {
        theGrid.indexer.localIndexToRealGrid(localIx, from: centerGridCell)
    }

    static func first(
        fromCenterAt absoluteGridIndex: Int, cCells: Int,
        where predicate: @escaping (GridCell, AKPoint) -> Bool
    ) -> (GridCell, AKPoint)? {
        theGrid.indexer.first(
            fromCenterAt: absoluteGridIndex, cCells: cCells, where: predicate
        )
    }

    static func first(
        fromCenterAt centerCell: GridCell, cCells: Int,
        where predicate: @escaping (GridCell, AKPoint) -> Bool
    ) -> (GridCell, AKPoint)? {
        theGrid.indexer.first(
            fromCenterAt: centerCell, cCells: cCells, where: predicate
        )
    }

    static func cellAt(_ absoluteIndex: Int) -> GridCell    { theGrid.core.cellAt(absoluteIndex) }
    static func cellAt(_ gridPoint: AKPoint) -> GridCell    { theGrid.core.cellAt(gridPoint) }
    static func mannaAt(_ absoluteIndex: Int) -> Manna?     { theGrid.manna.mannaAt(absoluteIndex) }
}

extension Grid {
    static func gridPosition(of index: Int) -> AKPoint {
        theGrid.core.gridPosition(of: index)
    }

    static func randomCellIndex() -> Int {
        let cCellsInGrid = theGrid.core.gridDimensionsCells.area()
        return Int.random(in: 0..<cCellsInGrid)
    }

    static func randomCell() -> GridCell { cellAt(randomCellIndex()) }
}
