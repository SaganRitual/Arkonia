class IngridArkons {
    // A reason to choose unsafe buffers rather than contiguous arrays: the
    // thread sanitizer in the debugger counts the entire contiguous array as
    // a single object, so if you have one thread hitting one cell in the array,
    // and another thread hitting a differet cell in the array, the debugger will
    // halt and say it's an access race. Unsafe buffers don't exhibit that behavior
    //
    // Of course, that means we have to manage our own reference counting,
    // but that's fortunately very straightforward here -- retain when the arkon
    // is first placed on the grid, release when the arkon dies
    var allTheArkons: UnsafeMutableBufferPointer<Unmanaged<Stepper>?>

    init(_ cCells: Int) {
        allTheArkons = .allocate(capacity: cCells)
        allTheArkons.initialize(repeating: nil)
    }

    func arkonAt(_ absoluteIndex: Int) -> Stepper? { allTheArkons[absoluteIndex]?.takeUnretainedValue() }

    func arkonAt(_ absolutePosition: AKPoint) -> Stepper? {
        let ax = Ingrid.absoluteIndex(of: absolutePosition)
        return allTheArkons[ax]?.takeUnretainedValue()
    }

    func moveArkon(_ stepper: Stepper, fromCell: IngridCell, toCell: IngridCell) {
        let fromContents = Ingrid.shared.getContents(in: fromCell.absoluteIndex)
        let toContents = Ingrid.shared.getContents(in: toCell.absoluteIndex)

        Debug.log(level: 198) { "moveArkon \(stepper.name) from abs ix \(fromCell.absoluteIndex)(\(fromContents)) to \(toCell.absoluteIndex)(\(toContents))" }
        hardAssert(allTheArkons[fromCell.absoluteIndex] != nil) { "huh-1?" }
        allTheArkons[toCell.absoluteIndex] = allTheArkons[fromCell.absoluteIndex]
        hardAssert(allTheArkons[fromCell.absoluteIndex] != nil) { "huh0?" }
        hardAssert(allTheArkons[toCell.absoluteIndex] != nil) { "huh?" }
        allTheArkons[fromCell.absoluteIndex] = nil
        stepper.ingridCellAbsoluteIndex = toCell.absoluteIndex
        hardAssert(allTheArkons[toCell.absoluteIndex] != nil) { "huh2?" }
    }

    // We don't need to lock this function, because it's only ever called
    // by the spawn cycle, which is accessing the cell through its sensor
    // pad, meaning it already owns the locks and no one else will be trying
    // to muck with them
    func placeArkon(_ stepper: Stepper, atIndex: Int) {
        hardAssert(Ingrid.shared.getContents(in: atIndex) != .arkon) { "placeArkon" }
        allTheArkons[atIndex] = Unmanaged.passRetained(stepper)
        stepper.ingridCellAbsoluteIndex = atIndex

        Debug.log(level: 198) { "placeArkon \(stepper.name) at abs ix \(atIndex)" }
    }

    // Unlike placeArkon(), this function must be called only for locked cells,
    // so never call it directly, instead call the Ingrid version, which knows
    // how to lock stuff
    func releaseArkon(_ stepper: Stepper) -> Int {
        Debug.log(level: 198) { "releaseArkon \(stepper.name) at abs ix \(stepper.ingridCellAbsoluteIndex)" }

        allTheArkons[stepper.ingridCellAbsoluteIndex]!.release()
        allTheArkons[stepper.ingridCellAbsoluteIndex] = nil

        // For debugging; invalid index will crash anyone trying to use the
        // stepper's index to address the grid after we just now released th cell
        defer { stepper.ingridCellAbsoluteIndex = -4242 }
        return stepper.ingridCellAbsoluteIndex
    }
}
