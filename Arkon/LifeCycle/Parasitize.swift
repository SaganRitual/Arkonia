import SpriteKit

extension Stepper {
    func parasitize() {
        let (attackTargetCell, attackTargetGridPosition) = Grid.cellAt(
            jumpSpec!.attackTargetIndex, from: jumpSpec!.from
        )

        if isWithinSensorRange(attackTargetGridPosition) &&
            isLockedByMe(attackTargetCell) &&
            hasArkon(attackTargetCell) {

            let victim = attackTargetCell.contents.arkon!
            victim.arkon.isDyingFromParasite = true
            

            let swell = SKAction.scale(by: 1.2, duration: 0.05)
            let shrink = swell.reversed()
            let sequence = SKAction.sequence([swell, shrink])
            let `repeat` = SKAction.repeat(sequence, count: 4)
            thorax.run(`repeat`, completion: disengageGrid)
            return
        }

        disengageGrid()
    }
}

func abs(_ position: AKPoint) -> AKPoint {
    AKPoint(x: abs(position.x), y: abs(position.y))
}

private extension Stepper {
    func hasArkon(_ cell: GridCell) -> Bool { cell.contents.hasArkon() }

    func isLockedByMe(_ cell: GridCell) -> Bool {
        let fromGridPosition = jumpSpec!.from.properties.gridPosition
        let offset = abs(cell.properties.gridPosition) - abs(fromGridPosition)
        let localIndex = GridIndexer.offsetToLocalIndex(offset)
        return sensorPad.theSensors[localIndex].iHaveTheLiveConnection
    }

    func isWithinSensorRange(_ gridPosition: AKPoint) -> Bool {
        let offset = gridPosition - jumpSpec!.from.properties.gridPosition
        let maxOffset = net.netStructure.cSenseRings
        return abs(offset.x) <= maxOffset  && abs(offset.y) <= maxOffset
    }
}
