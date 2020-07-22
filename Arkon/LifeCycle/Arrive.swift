import SpriteKit

extension Stepper {
    func arrive() { mainDispatch(arrive_B) }

    private func arrive_B() {
        Debug.log(level: 213) { "arrive" }
        Debug.debugColor(self, .brown, .green)

        let ax = spindle.gridCell.properties.gridAbsoluteIndex
        if let manna = Grid.mannaAt(ax) { graze(manna); return }

        self.disengageGrid()
    }

    private func graze(_ manna: Manna) {
        Debug.log(level: 213) { "graze" }
        censusData.increment(.foodHits)
        manna.harvest {
            Debug.log(level: 213) { "harvest" }
            if let mannaContent = $0 { self.metabolism.eat(mannaContent) }
            self.disengageGrid()
        }
    }
}
