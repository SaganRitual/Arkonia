import SpriteKit

extension Stepper {
    func arrive() { MainDispatchQueue.async(execute: arrive_) }

    private func arrive_() {
        Debug.log(level: 206) { "arrive" }
        Debug.debugColor(self, .brown, .green)

        let ax = sensorPad.centerAbsoluteIndex!
        if let manna = Grid.mannaAt(ax) { graze(manna); return }

        self.disengageGrid()
    }

    private func graze(_ manna: Manna) {
        Debug.log(level: 206) { "graze" }
        cFoodHits += 1
        manna.harvest {
            if let mannaContent = $0 { self.metabolism.eat(mannaContent) }
            self.disengageGrid()
        }
    }
}
