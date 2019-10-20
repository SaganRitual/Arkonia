import SpriteKit

extension Shift {
    func shift(
        whereIAmNow: Gridlet,
        onComplete: @escaping LockVoid.LockOnComplete
    ) {
        Grid.lock({ [weak self] () -> [Void]? in
            guard let myself = self else {
//                print("Bailing in Shift.shift")
                return nil
            }

            myself.shift_(whereIAmNow: whereIAmNow, onComplete: onComplete)
            return nil
        })
    }

    private func shift_(
        whereIAmNow: Gridlet,
        onComplete: @escaping LockVoid.LockOnComplete
    ) {
        guard let st = stepper else { fatalError() }

//        print("newGridlet = \(st.shiftTarget) from \(whereIAmNow.gridPosition + st.shiftTarget)")
        let newGridlet = Gridlet.at(whereIAmNow.gridPosition + st.shiftTarget)

        let action = SKAction.move(to: newGridlet.scenePosition, duration: 0.1)
        st.sprite.run(action) { onComplete(nil) }
    }
}
