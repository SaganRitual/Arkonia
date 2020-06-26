import SpriteKit

extension Stepper {
    func abandonNewborn() {
        let rotate = SKAction.rotate(byAngle: CGFloat.tau, duration: 0.25)

        thorax.run(rotate)

        MainDispatchQueue.async {
            self.metabolism.detachOffspring()
            self.disengageGrid()
        }
    }

    static func makeNewArkon(_ parentArkon: Stepper?) {
        let spindleTarget_ = setSpindleTarget(parentArkon)
        let spindleTarget = spindleTarget_ ?? Grid.randomCell()

        Debug.log(level: 213) {
            "makeNewArkon"
                + "; parent \(AKName(parentArkon?.name)) at \(String(describing: parentArkon?.spindle.gridCell.properties.gridPosition))"
            + ", newborn at \(spindleTarget.properties.gridPosition)"
        }

        spawn(
            from: parentArkon, at: spindleTarget,
            spindleTargetIsPreLocked: spindleTarget_ != nil
        )
    }
}

private extension Stepper {
    static func setSpindleTarget(_ parentIf: Stepper?) -> GridCell? {
        var spindleTarget: GridCell?

        if let pa = parentIf,
           let bc = pa.sensorPad.getFirstTargetableCell(startingAt: 1) {
            spindleTarget = bc.liveGridCell

            assert(bc.iHaveTheLiveConnection && bc.liveGridCell?.lock.isLocked ?? false)

            bc.iHaveTheLiveConnection = false   // Offspring needs it; we're blind to it now
        }

        return spindleTarget
    }

    static func spawn(
        from parent: Stepper?, at spindleTarget: GridCell,
        spindleTargetIsPreLocked: Bool
    ) {
        MainDispatchQueue.async { spawn_B() }

        func spawn_B() {
            if parent != nil { Debug.debugColor(parent!, .blue, .purple) }

            let embryo = ArkonEmbryo(
                parent, spindleTarget,
                spindleTargetIsPreLocked: spindleTargetIsPreLocked
            )

            embryo.beginLife(parent?.abandonNewborn)
        }
    }
}
