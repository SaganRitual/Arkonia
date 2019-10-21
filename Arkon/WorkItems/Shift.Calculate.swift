import SpriteKit

extension Stepper {

    func calculateShift(_ nothing: [Void]? = nil) {
        guard let sh = shifter else { fatalError() }
        sh.calculateShift()
    }
}

extension Shifter {

    func calculateShift() {
        func workItem() -> [Void]? {
            calculateShift_()
            return nil
        }

        func next(_ nothing: [Void]?) { stepper.shiftShift() }

        Grid.lock(workItem, next)
    }

    private func calculateShift_() {
        let senseData = loadSenseData()
        let shiftTarget = selectMoveTarget(senseData: senseData)

        releaseGridPoints_(keep: shiftTarget)
    }

    private func getMotorDataAsDictionary(_ senseData: [Double]) -> [Int: Double] {
        return senseData.enumerated().reduce([:]) { accumulated, pw in
            let (position, weight) = pw
            var t = accumulated
            t[position] = weight
            return t
        }
    }

    private func loadSenseData() -> [Double] {
        var (hackyRearrangedInputs, nutritionses) =
            self.sensoryInputs.reduce(into: ([Double](), [Double]()))
        {
            $0.0.append($1.0)
            $0.1.append($1.1)
        }

        let whereIAmNow = stepper.gridlet!
        let previousShift = stepper.previousShift

        hackyRearrangedInputs.append(contentsOf: nutritionses)

        let xGrid = Double(whereIAmNow.gridPosition.x)
        let yGrid = Double(whereIAmNow.gridPosition.y)
        hackyRearrangedInputs.append(contentsOf: [xGrid, yGrid])

        let xShift = Double(previousShift.x)
        let yShift = Double(previousShift.y)
        hackyRearrangedInputs.append(contentsOf: [xShift, yShift])

        return hackyRearrangedInputs
    }

    private func releaseGridPoints(keep: AKPoint? = nil) {
        func workItem() -> [Void]? { releaseGridPoints_(keep: keep); return  nil}
        Grid.lock(workItem)
    }

    private func releaseGridPoints_(keep: AKPoint? = nil) {
        let whereIAmNow = stepper.gridlet!

        func engage() -> [Void]? {
            for gridOffset in usableGridOffsets {

                if keep == nil || keep! != gridOffset {
                    let targetGridlet =  Gridlet.at(whereIAmNow.gridPosition + gridOffset)
                    targetGridlet.gridletIsEngaged = false
                }
            }

            usableGridOffsets.removeAll(keepingCapacity: true)
            return nil
        }
    }

    private func selectMoveTarget(senseData: [Double]) -> AKPoint {

        let motorOutputs: [Double] = stepper.net.getMotorOutputs(senseData)
        let dMotorOutputs: [Int: Double] = self.getMotorDataAsDictionary(motorOutputs)

        let order: [(Int, Double)] = dMotorOutputs.sorted { lhs, rhs in
            Double(lhs.1) > Double(rhs.1)
        }

        var targetShift = AKPoint.zero
        let targetMove = order.first { entry in
            targetShift = Grid.moves[entry.0]
            return usableGridOffsets.contains(targetShift)
        }

        guard let tm = targetMove else { return AKPoint.zero }
        return Grid.moves[tm.0]
    }
}
