import SpriteKit

extension Shifter {
    func moveSprite() {
        guard let scr = scratch else { fatalError() }
        guard let st = scr.stepper else { fatalError() }
        guard let gcc = scr.gridCellConnector as? SafeStage else { fatalError() }
//        Log.L.write("moveSprite \(six(st.name))")

        let moveDuration: TimeInterval = 0.1
        let position = gcc.to.randomScenePosition ?? gcc.to.scenePosition

        let moveAction = gcc.willMove ?
            SKAction.move(to: position, duration: moveDuration) :
            SKAction.wait(forDuration: moveDuration)

        let anotherMove = SKAction.run(moveStepper)

        let moveSequence = SKAction.sequence([moveAction, anotherMove])

        st.sprite.run(moveSequence)
    }

    func moveStepper() {
        guard let scr = scratch else { fatalError() }
        guard let st = scr.stepper else { fatalError() }
        guard let gcc = scr.gridCellConnector as? SafeStage else { fatalError() }
//        Log.L.write("moveStepper \(six(st.name))")

        gcc.move()
        st.gridCell = GridCell.at(gcc.to)
        postMove()
    }
}

extension Shifter {
    func postMove() {
        Log.L.write("post move \(six(self.scratch?.stepper?.name))")
        guard let scr = scratch else { fatalError() }
        guard let gcc = scratch?.stage else { fatalError() }
        guard let dp = scr.dispatch else { fatalError() }

        if gcc.willMove && gcc.to.contents != .nothing {
//            Log.L.write("post move to eat \(six(self.scratch?.stepper?.name))")
            dp.currentTask = nil
            dp.eat()
            return
        }

        Grid.shared.concurrentQueue.sync(flags: .barrier) {
            Log.L.write("nil1 = \(scr.gridCellConnector == nil)")
            scr.gridCellConnector = nil
//            Log.L.write("post move to funge \(six(self.scratch?.stepper?.name))")
            dp.currentTask = nil
            dp.funge()
        }
//        Log.L.write("nil2 = \(scr.gridCellConnector == nil)")
    }
}
