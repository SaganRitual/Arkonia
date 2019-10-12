import SpriteKit

extension Shift {
    func shift(whereIAmNow: Gridlet, completion: @escaping CoordinatorCallback) {
        guard let st = stepper else { fatalError() }
        guard let sp = st.sprite else { print("bailing in Shift.shift()"); return }

        let newGridlet = Gridlet.at(whereIAmNow.gridPosition + st.shiftTarget)
        newGridlet.sprite = self.stepper!.sprite
        self.stepper!.gridlet = newGridlet

        let action = SKAction.move(to: newGridlet.scenePosition, duration: 0.1)
        sp.run(action, completion: completion)
    }
}
