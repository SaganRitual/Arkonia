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

                b()
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
            Debug.log(level: 152) { "motorOutput \(motorOutputs) -> \(motorOutput)" }

            // Try to use the selected motor output, ie, jump to that square on
            // the grid. But if that square is occupied, lay out a selection array
            // that makes "stand still" the least likely option. If the motor
            // output is 0 already, we just take it as is.
            //
            // Say we have 9 squares, meaning the 0 square where we are right now, and
            // the 8 around us. If the motor output is 3, then we set up the selection
            // array like 3, 4, 5, 6, 7, 8, 9, 1, 2, 0
            //
            let selector: [Int]
            if motorOutput > 0 {
                selector = [motorOutput] +
                            ((motorOutput + 1)..<(Plotter.cMotorGridlets + 1)).map { $0 } +
                            (1..<motorOutput).map { $0 } +
                            [0]
            } else {
                selector = [0]
            }

            var targetOffset: Int = 0
            if let toff = selector.first(where: {
                senseGrid.cells[$0] is HotKey && (senseGrid.cells[$0].contents != .arkon || $0 == 0)
            }) { targetOffset = toff }

            Debug.log(level: 152) { "toff \(targetOffset) from selector \(selector)" }

            let fromCell: HotKey?
            let toCell: HotKey

            if targetOffset == 0 {
                guard let t = senseGrid.cells[targetOffset] as? HotKey else { fatalError() }

                toCell = t; fromCell = nil
                Debug.log(level: 104) { "toCell at \(t.gridPosition) holds \(six(t.sprite?.name))" }
            } else {
                guard let t = senseGrid.cells[targetOffset] as? HotKey else { fatalError() }
                guard let f = senseGrid.cells[0] as? HotKey else { fatalError() }

                toCell = t; fromCell = f
                Debug.log(level: 104) {
                    let m = senseGrid.cells.map { "\($0.gridPosition) \(type(of: $0)) \($0.contents)" }

                    return "I am \(six(st.name))" +
                    "; toCell at \(t.gridPosition) holds \(six(t.sprite?.name))" +
                    ", fromCell at \(f.gridPosition) holds \(six(f.sprite?.name))\n" +
                    "senseGrid(\(m)"
                }

                assert(fromCell?.contents ?? .nothing == .arkon)
            }

            Debug.log(level: 98) { "targetOffset: \(targetOffset)" }

            assert((fromCell?.contents ?? .arkon) == .arkon)
            onComplete(CellShuttle(fromCell, toCell))
        }

        a()
    }
}
