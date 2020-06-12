import SpriteKit

extension Stepper {
    func abandonNewborn() {
        let rotate = SKAction.rotate(byAngle: CGFloat.tau, duration: 0.25)

        func abandonNewborn_A() { thorax.run(rotate); abandonNewborn_B() }
        func abandonNewborn_B() { MainDispatchQueue.async(execute: abandonNewborn_C) }
        func abandonNewborn_C() {
            metabolism.detachOffspring()
            disengageGrid()
        }

        abandonNewborn_A()
    }
}

extension Stepper {
    private static func spawn(from parent: Stepper?, at birthCell: GridCell) {

        func spawn_A() { MainDispatchQueue.async(execute: spawn_B) }

        func spawn_B() {
            if parent != nil { Debug.debugColor(parent!, .blue, .purple) }

            let embryo = ArkonEmbryo(parent, birthCell)
            embryo.beginLife(parent?.abandonNewborn)
        }

        spawn_A()
    }

    static func makeNewArkon(_ parentArkon: Stepper?) {
        if let pa = parentArkon,
           let padCell = pa.sensorPad.getFirstTargetableCell(startingAt: 1),
           let liveGridCell = padCell.liveGridCell {
            spawn(from: pa, at: liveGridCell)
        } else {
            Grid.lockRandomCell { self.spawn(from: nil, at: $0) }
        }
    }
}
