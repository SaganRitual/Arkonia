import CoreGraphics

// swiftlint:disable function_body_length

extension Plotter {
    static let cMotorGridlets = Arkonia.cMotorGridlets
    static var cNaN = 0
    static var cInf = 0

    func setRoute(
        _ senseData: [Double], _ senseGrid: CellSenseGrid, _ onComplete: @escaping (CellShuttle) -> Void
    ) {
        guard let ch = scratch else { fatalError() }
        guard let st = ch.stepper else { fatalError() }
        guard let net = st.net else { fatalError() }

        Debug.log(level: 119) { "makeCellShuttle for \(six(st.name)) from \(st.gridCell!)" }
        Debug.log(level: 122) { "senseData \(senseData)" }

        var motorOutputs = [(Int, Double)]()

        func a() {
            net.getMotorOutputs(senseData) { rawOutputs in
                Debug.log(level: 145) { "rawOutputs \(rawOutputs)" }

                motorOutputs = zip(0..., rawOutputs).compactMap { position, rawOutput in
                    if rawOutput.isNaN {
                        Plotter.cNaN += 1
                        Debug.log { "NaN \(Plotter.cNaN)" }
                        return nil
                    }

                    if rawOutput.isInfinite {
                        Plotter.cInf += 1
                        Debug.log { "cInf \(Plotter.cInf)" }
                        return nil
                    }

                    return (position, rawOutput)
                }

                // Get off the computation thread as quickly as possible
                Dispatch.dispatchQueue.async(execute: b)
            }
        }

        func b() {
            let motorOutput_ = motorOutputs[0].1

            // Divide the circle into cMotorGridlets + 1 slices
            let s0 = motorOutput_
            let s1 = s0 * Double(Plotter.cMotorGridlets + 1)
            let s2 = floor(s1)
            let s3 = Int(s2)
            let motorOutput = s3
            Debug.log(level: 154) { "motorOutput \(motorOutputs) -> \(motorOutput)" }

            let targetOffset = calculateTargetOffset(for: motorOutput, from: senseGrid.cells)

            Debug.log(level: 154) { "toff \(targetOffset) from motorOutput \(motorOutput)" }

            let fromCell: HotKey?
            let toCell: HotKey

            if targetOffset == 0 {
                guard let t = senseGrid.cells[targetOffset] as? HotKey else { fatalError() }

                toCell = t; fromCell = nil
            } else {
                guard let t = senseGrid.cells[targetOffset] as? HotKey else { fatalError() }
                guard let f = senseGrid.cells[0] as? HotKey else { fatalError() }

                toCell = t; fromCell = f
            }

            if targetOffset == 0 { Debug.log(level: 164) { "targetOffset \(targetOffset) for \(st.name)" } }

            onComplete(CellShuttle(fromCell, toCell))
        }

        a()
    }

    func calculateTargetOffset(for motorOutput: Int, from cells: [GridCellKey]) -> Int {
        // Try to use the selected motor output, ie, jump to that square on
        // the grid. But if that square is occupied, lay out a selection array
        // that makes "stand still" the least likely option. If the motor
        // output is 0 already, we just take it as is.
        //
        // Say we have 9 squares, meaning the 0 square where we are right now, and
        // the 8 around us. If the motor output is 3, then we set up the selection
        // array like 3, 4, 5, 6, 7, 8, 9, 1, 2, 0
        //
        for m in 0..<Plotter.cMotorGridlets {
            let select = (m + motorOutput) % Plotter.cMotorGridlets
            if select == 0 { continue }

            if cells[select] is HotKey &&
                (cells[select].stepper == nil || select == 0) {
                return select
            }
        }

        return 0
    }
}
