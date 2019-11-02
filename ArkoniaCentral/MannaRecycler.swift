import SpriteKit

extension MannaCoordinator {
    struct MannaRecycler {
        static let colorAction = SKAction.colorize(
            with: .orange, colorBlendFactor: 1.0,
            duration: Manna.fullGrowthDurationSeconds
        )

        static let fadeInAction = SKAction.fadeIn(withDuration: 0.001)

        private weak var gridlet: Gridlet!
        private weak var manna: Manna!
        private weak var mannaCoordinator: MannaCoordinator!

        init(
            _ manna: Manna,
            _ gridlet: Gridlet,
            _ mannaCoordinator: MannaCoordinator
        ) {
            self.manna = manna
            self.gridlet = gridlet
            self.mannaCoordinator = mannaCoordinator
        }

        func go() { fadeOut() }
    }
}

extension MannaCoordinator.MannaRecycler {

    private func fadeIn() {
        manna.sprite.run(
            MannaCoordinator.MannaRecycler.fadeInAction
        ) {
            self.manna.sprite.run(
                MannaCoordinator.MannaRecycler.colorAction
            ) {
                self.manna.sprite.userData!["recycler"] = nil
            }
        }
    }

    private func getWaitAction(_ rebloomDelay: TimeInterval) -> SKAction {
        return SKAction.wait(forDuration: rebloomDelay)
    }

    private func fadeOut() {
        let fadeOut = SKAction.fadeOut(withDuration: 0.001)
        let wait = getWaitAction(0.001)//manna.rebloomDelay)
        let deathSequence = SKAction.sequence([fadeOut, wait])

        manna.sprite.run(deathSequence, completion: replant)
    }

    private func replant() {
        MannaCoordinator.plantSingleManna(self.manna, at: self.gridlet)
        fadeIn()
    }
}
