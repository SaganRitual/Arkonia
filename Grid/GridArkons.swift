class GridArkons {
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

    func moveArkon(_ stepper: Stepper, from fromCellIndex: Int, to toCellIndex: Int) {
        allTheArkons[toCellIndex] = allTheArkons[fromCellIndex]!
        allTheArkons[fromCellIndex] = nil
        stepper.sensorPad.centerAbsoluteIndex = toCellIndex
    }

    // We don't need to lock this function, because it's only ever called
    // by the spawn cycle, which is accessing the cell through its sensor
    // pad, meaning it already owns the locks and no one else will be trying
    // to muck with them
    func placeArkon(_ stepper: Stepper, atIndex: Int) {
        allTheArkons[atIndex] = Unmanaged.passRetained(stepper)
        stepper.sensorPad.centerAbsoluteIndex = atIndex
    }

    // Unlike placeArkon(), this function must be called only for locked cells,
    // so never call it directly, instead call the Grid version, which knows
    // how to lock stuff
    func removeArkon(_ stepper: Stepper) -> Int {
        allTheArkons[stepper.sensorPad.centerAbsoluteIndex]!.release()
        allTheArkons[stepper.sensorPad.centerAbsoluteIndex] = nil
        return stepper.sensorPad.centerAbsoluteIndex
    }
}
