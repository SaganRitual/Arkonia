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
                Debug.log(level: 145) { "rawOutputs \(rawOutputs)" }

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

            // Divide the circle into 8 + 1 slices
            // Note: range of Arkonia.netActivator = sigmoid is -1...1

//            let s0 = motorOutput_ + 1   // s0 range is 0...2
//            let s1 = s0 / 2.0           // s1 range is 0...1
//            let s2 = s1 * Double(Arkonia.cMotorGridlets + 1)
//            let s3 = ceil(s2) - 1
//            let motorOutput = Int(s3) // Int((motorOutput_ + 1) / 2.0 * Double(Arkonia.cMotorGridlets + 1))
            let s0 = motorOutput_ + 1
            let s1 = s0 * Double(Arkonia.cMotorGridlets + 1) / 2
            let s2 = ceil(s1)
            let s3 = Int(s2)
            let motorOutput = s3 - 1
            Debug.log(level: 143) { "motorOutput \(motorOutputs), \(s0), \(s1), \(s2), \(s3) -> \(motorOutput)" }

            Plot.motorHistogram[motorOutput] += 1

            var skip = 0
            let gridlets: [Int] = (0..<(Arkonia.cMotorGridlets + 1)).map { wrappingIndex in
                if wrappingIndex == 0 { return motorOutput }

                let wrapped = wrappingIndex % (Arkonia.cMotorGridlets + 1)

                if wrapped == motorOutput { skip = 1 }

                return (wrappingIndex + skip) % (Arkonia.cMotorGridlets + 1)
            }

            var targetOffset: Int = 0
            if let toff = gridlets.first(where: {
                senseGrid.cells[$0] is HotKey && (senseGrid.cells[$0].contents != .arkon || $0 == 0)
            }) { targetOffset = toff }

            Debug.log(level: 139) { "toff \(targetOffset) from gridlets \(gridlets)" }

//            let sinss = Int((sin(motorOutput_) + 1) / 2 * Double(Arkonia.cMotorGridlets))
//            Plot.sinHistogram[sinss] += 1
//            Debug.log(level: 132) { return targetOffset == 0 ? "toff = 0, motorOutput_ = \(motorOutput_)" : nil }
            Plot.targetHistogram[targetOffset] += 1
            Debug.log(level: 143) { "sins/targets/motors <- \(Plot.targetHistogram) <- \(Plot.motorHistogram)" }

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
