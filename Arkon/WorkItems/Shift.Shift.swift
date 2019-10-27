import SpriteKit

extension Stepper {

    func shiftShift(_ targetOffset: AKPoint) {
//        print("shiftShift \(name)")
        guard let sh = shifter else { fatalError() }
        sh.shift(targetOffset)
    }
}

extension Shift {
    func shift(_ targetOffset: AKPoint) {
        func execute() -> [Gridlet]? { teardown_(targetOffset); return nil }

//        print("goober")
        Grid.lock(execute)
    }

    private func teardown_(_ targetOffset: AKPoint) {
        func partA() {
            let whereIAmNow = stepper.gridlet.gridPosition
            let newGridlet = Gridlet.at(whereIAmNow + targetOffset)

//            print("stepper \(stepper.name) move from \(stepper.gridlet.gridPosition) to \(newGridlet.gridPosition)")

            let moveAction = SKAction.move(to: newGridlet.scenePosition, duration: 0.1)
            stepper.sprite.run(moveAction, completion: partB)
        }

        func partB() {
//            print("move action, stepper arrive \(self.stepper.name)")
            World.lock( { [unowned self] () -> [Stepper]? in
                guard let stepper = self.stepper else { fatalError() }
                stepper.shifter = nil
                return [stepper]
            }, { sts in
                guard let stepper = sts?[0] else { fatalError() }
                stepper.arrive(targetOffset)
            },
                .concurrent
            )
        }

        partA()
    }
}
