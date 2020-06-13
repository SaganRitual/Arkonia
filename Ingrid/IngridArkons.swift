class IngridArkons {
    // A reason to choose unsafe buffers rather than contiguous arrays: the
    // thread sanitizer in the debugger counts the entire contiguous array as
    // a single object, so if you have one thread hitting one cell in the array,
    // and another thread hitting a differet cell in the array, the debugger will
    // halt and say it's an access race. Unsafe buffers don't exhibit that behavior
    var allTheArkons: UnsafeMutableBufferPointer<Stepper?>

    init(_ cCells: Int) {
        allTheArkons = .allocate(capacity: cCells)
        allTheArkons.initialize(repeating: nil)
    }

    func arkonAt(_ absoluteIndex: Int) -> Stepper? { allTheArkons[absoluteIndex] }

    func arkonAt(_ absolutePosition: AKPoint) -> Stepper? {
        let ax = Ingrid.absoluteIndex(of: absolutePosition)
        return allTheArkons[ax]
    }

    func moveArkon(_ stepper: Stepper, fromIndex: Int, toIndex: Int) {
        allTheArkons[fromIndex] = nil
        allTheArkons[toIndex] = stepper
        stepper.ingridCellAbsoluteIndex = toIndex
    }

    func placeArkon(_ stepper: Stepper, atIndex: Int) {
        allTheArkons[atIndex] = stepper
    }

    func releaseArkon(_ stepper: Stepper) {
        allTheArkons[stepper.ingridCellAbsoluteIndex] = nil
    }
}
