import SpriteKit

extension Shift {
    func shift(whereIAmNow: Gridlet, completion: @escaping CoordinatorCallback) {
        Lockable<Void>().lock({ [weak self] in
            guard let myself = self else {
//                print("Bailing in Shift.shift")
                return
            }
            myself.shift_(whereIAmNow: whereIAmNow, completion: completion)
        }, {})
    }

    private func shift_(whereIAmNow: Gridlet, completion: @escaping CoordinatorCallback) {
        guard let st = stepper else { fatalError() }

//        print("newGridlet = \(st.shiftTarget) from \(whereIAmNow.gridPosition + st.shiftTarget)")
        let newGridlet = Gridlet.at(whereIAmNow.gridPosition + st.shiftTarget)

        let action = SKAction.move(to: newGridlet.scenePosition, duration: 0.1)
        st.sprite.run(action, completion: completion)
    }
}
