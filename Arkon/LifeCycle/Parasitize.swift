import SpriteKit

extension Stepper {
    func parasitize() {
        let (attackTargetCell, attackTargetGridPosition) = Grid.cellAt(
            jumpSpec!.attackTargetIndex, from: jumpSpec!.from
        )

        if isWithinSensorRange(attackTargetGridPosition) &&
            isLockedByMe(attackTargetCell) {
            let swell = SKAction.scale(by: 1.2, duration: 0.05)
            let shrink = swell.reversed()
            let sequence = SKAction.sequence([swell, shrink])
            let `repeat` = SKAction.repeat(sequence, count: 4)
            thorax.run(`repeat`)
        }

        disengageGrid()
    }
}

extension Stepper {
    func isLockedByMe(_ cell: GridCell) -> Bool {
        return Bool.random()
    }

    func isWithinSensorRange(_ gridPosition: AKPoint) -> Bool {
        let offset = gridPosition - jumpSpec!.from.properties.gridPosition
        let maxOffset = net.netStructure.cSenseRings
        return abs(offset.x) <= maxOffset  && abs(offset.y) <= maxOffset
    }
}
