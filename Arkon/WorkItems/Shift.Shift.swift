import SpriteKit

extension Stepper {

    func shiftShift(_ nothing: [Void]? = nil) {
        guard let sh = shifter else { fatalError() }
        sh.shift()
    }
}

extension Shifter {
    func shift() {
        Grid.lock(setup_, finalize_, .continueBarrier)
    }

    private func finalize_(_ newGridlets: [Gridlet]?) {
        guard let newGridlet = newGridlets?[0] else { fatalError() }

        let action = SKAction.move(to: newGridlet.scenePosition, duration: 0.1)

        stepper.sprite.run(action) { [unowned self] in
            self.stepper.arrive()
        }
    }

    private func setup_() -> [Gridlet]? {
        let whereIAmNow = stepper.gridlet.gridPosition
        let newGridlet = Gridlet.at(whereIAmNow + stepper.shiftTarget)

        self.stepper.shifter = nil

        return [newGridlet]
    }
}
