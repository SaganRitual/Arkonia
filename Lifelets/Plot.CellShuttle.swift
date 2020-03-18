import CoreGraphics

// swiftlint:disable function_body_length
extension Plot {
    static var cNaN = 0
    static var cInf = 0
    static var motorHistogram = [Int](repeating: 0, count: Arkonia.cMotorGridlets + 1)
    static var targetHistogram = [Int](repeating: 0, count: Arkonia.cMotorGridlets + 1)
    static var sinHistogram = [Int](repeating: 0, count: Arkonia.cMotorGridlets + 1)

    func makeCellShuttle(
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

                motorOutputs = zip(0..., rawOutputs).compactMap { position, rawOutput in
                    if rawOutput.isNaN {
                        Plot.cNaN += 1
                        Debug.log { "NaN \(Plot.cNaN)" }
                        return nil
                    }

                    if rawOutput.isInfinite {
                        Plot.cInf += 1
                        Debug.log { "cInf \(Plot.cInf)" }
                        return nil
                    }

                    return (position, rawOutput)
                }

                b()
            }
        }

        func b() {
            let motorOutput_ = motorOutputs[0].1

            // Take anything < 1 as a fraction of 2π
//            if abs(motorOutput_) <= 1 { motorOutput_ *= Double.pi }

            // Divide the circle into 8 slices

            let s1 = sin(motorOutput_)
            assert(s1 <= 1 && s1 >= -1)
            let s2 = asin(s1) + (Double.pi / 2)
            assert(s2 >= 0 && s2 <= Double.pi)
            let s3 = s2 / Double.pi
            assert(s3 >= 0 && s3 <= 1)
            let s4 = Double(Arkonia.cMotorGridlets + 1)
            let s5 = s3 * s4
            let motorOutput = Int(s5)// Int((sin(motorOutput_) + 1) / 2 * Double(Arkonia.cMotorGridlets + 1))
            assert(motorOutput >= 0 && motorOutput <= Arkonia.cMotorGridlets + 1)
            Debug.log(level: 131) { "motorOutput \(motorOutputs), single \(motorOutput)" }

            Plot.motorHistogram[motorOutput] += 1

            let gridlets = (0..<(Arkonia.cMotorGridlets + 1)).map { wrappingIndex in
                (motorOutput + wrappingIndex) % (Arkonia.cMotorGridlets + 1)
            }

            guard let targetOffset = gridlets.first(where: { senseGrid.cells[$0] is HotKey })
                else { fatalError() }

            Debug.log(level: 132) { "toff \(targetOffset) from gridlets \(gridlets)" }

//            let sinss = Int((sin(motorOutput_) + 1) / 2 * Double(Arkonia.cMotorGridlets))
//            Plot.sinHistogram[sinss] += 1
//            Debug.log(level: 132) { return targetOffset == 0 ? "toff = 0, motorOutput_ = \(motorOutput_)" : nil }
            Plot.targetHistogram[targetOffset] += 1
            Debug.log(level: 132) { "sins/targets/motors <- \(Plot.targetHistogram) <- \(Plot.motorHistogram)" }

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
