extension Spawn {

    private func getGridPointNearParent() -> Gridlet? {
        guard let st = newStepper.parentStepper else { fatalError() }

        for offset in Grid.gridInputs {
            let offspringPosition = st.gridlet.gridPosition + offset

            if Gridlet.isOnGrid(offspringPosition.x, offspringPosition.y) {

                let gridlet = Gridlet.at(offspringPosition)
                if gridlet.contents == .nothing { return gridlet }
            }
        }

        return nil
    }

    func getLanding() {

        if newStepper.parentStepper != nil {
            if let rp = getGridPointNearParent() {
                newStepper.gridlet = rp
                return
            }
        }

        let gr = Gridlet.getRandomGridlet_()
        newStepper.gridlet = gr![0]
    }

}
