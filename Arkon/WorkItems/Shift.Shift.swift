import SpriteKit

extension Stepper {

    func shiftShift(_ targetOffset: AKPoint) {
//        print("shiftShift \(name)")
        guard let sh = shifter else { fatalError() }
        sh.shift(targetOffset)
    }
}

extension Shifter {
    func shift(_ targetOffset: AKPoint) {
        func execute() -> [Gridlet]? { teardown_(targetOffset); return nil }

        Grid.lock(execute)
    }

    private func teardown_(_ targetOffset: AKPoint) {
        let whereIAmNow = stepper.gridlet.gridPosition
        let newGridlet = Gridlet.at(whereIAmNow + targetOffset)

//        print("stepper \(stepper.name) move from \(stepper.gridlet.gridPosition) to \(newGridlet.gridPosition)")

        let moveAction = SKAction.move(to: newGridlet.scenePosition, duration: 0.1)
        let postMoveAction = SKAction.run { [unowned self] in
//            print("move action, stepper arrive \(self.stepper.name)")
            self.stepper.arrive(targetOffset)
            self.stepper.shifter = nil
        }

        let sequence = SKAction.sequence([moveAction, postMoveAction])

        stepper.sprite.run(sequence)
    }
}
