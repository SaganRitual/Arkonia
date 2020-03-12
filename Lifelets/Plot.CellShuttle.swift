import CoreGraphics

// swiftlint:disable function_body_length
extension Plot {
    static var cNaN = 0
    static var cInf = 0

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
                        print("NaN \(Plot.cNaN)")
                        return nil
                    }

                    if rawOutput.isInfinite {
                        Plot.cInf += 1
                        print("cInf \(Plot.cInf)")
                        return nil
                    }

                    return (position, rawOutput)
                }

                b()
            }
        }

        func b() {
            let trimmed = motorOutputs.filter { /*abs($0.1) < 1.0 &&*/ $0.0 != 0 }

            let order = trimmed.sorted { lhs, rhs in
                let labs = lhs.1//abs(lhs.1)
                let rabs = rhs.1//abs(rhs.1)

                return labs > rabs
            }

            Debug.log(level: 122) { "order \(order)" }

            let targetOffset = order.first { senseGrid.cells[$0.0] is HotKey }

            let fromCell: HotKey?
            let toCell: HotKey

            if targetOffset == nil || targetOffset!.0 == 0 {
                guard let t = senseGrid.cells[0] as? HotKey else { fatalError() }

                toCell = t; fromCell = nil
                Debug.log(level: 104) { "toCell at \(t.gridPosition) holds \(six(t.sprite?.name))" }
            } else {
                guard let t = senseGrid.cells[targetOffset!.0] as? HotKey else { fatalError() }
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

            if targetOffset == nil {
                Debug.log(level: 98) { "targetOffset: nil" }
            } else {
                Debug.log(level: 98) { "targetOffset: \(targetOffset!.0)" }
            }

            assert((fromCell?.contents ?? .arkon) == .arkon)
            onComplete(CellShuttle(fromCell, toCell))
        }

        a()
    }
}
