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

    func placeArkon(_ stepper: Stepper, atIndex: Int) {
        allTheArkons[atIndex] = Unmanaged.passRetained(stepper)
        stepper.ingridCellAbsoluteIndex = atIndex

        Debug.log(level: 198) { "placeArkon \(stepper.name) at abs ix \(atIndex)" }
    }

    func releaseArkon(_ stepper: Stepper) {
        Debug.log(level: 198) { "releaseArkon \(stepper.name) at abs ix \(stepper.ingridCellAbsoluteIndex)" }

        allTheArkons[stepper.ingridCellAbsoluteIndex]!.release()
        allTheArkons[stepper.ingridCellAbsoluteIndex] = nil
        stepper.ingridCellAbsoluteIndex = -4242
    }
}
