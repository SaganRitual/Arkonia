import SpriteKit

extension Shifter {
    func moveSprite() {
//        print("moveSprite")
        guard let scr = scratch else { fatalError() }
        guard let st = scr.stepper else { fatalError() }
        guard let gcc = scr.gridCellConnector as? SafeStage else { fatalError() }

        let moveDuration: TimeInterval = 0.1
        let moveAction = gcc.willMove ?
            SKAction.move(
                to: gcc.to.randomScenePosition ?? gcc.to.scenePosition, duration: moveDuration
            ) :
            SKAction.wait(forDuration: moveDuration)

        st.sprite.run(moveAction) {
            Grid.shared.concurrentQueue.async(execute: self.workItemMoveStepper!)
        }
    }

    func moveStepper() {
//        print("moveStepper")
        guard let scr = scratch else { fatalError() }
        guard let st = scr.stepper else { fatalError() }
        guard let gcc = scr.gridCellConnector as? SafeStage else { fatalError() }

        gcc.move()
        st.gridCell = GridCell.at(gcc.to)

        Grid.shared.concurrentQueue.async(execute: self.workItemPostMove!)
    }
}

extension Shifter {
    func postMove() {
//        print("postMove")
        guard let scr = scratch else { fatalError() }
        guard let gcc = scratch?.stage else { fatalError() }
        guard let dp = scr.dispatch else { fatalError() }

        if gcc.willMove && gcc.to.contents != .nothing {
//            print("lin")
            dp.eat()
            return
        }

//        print("nil1 = \(scr.gridCellConnector == nil)")
        Grid.shared.concurrentQueue.async(flags: .barrier) {
            scr.gridCellConnector = nil
            dp.funge()
        }
//        print("nil2 = \(scr.gridCellConnector == nil)")
    }
}
