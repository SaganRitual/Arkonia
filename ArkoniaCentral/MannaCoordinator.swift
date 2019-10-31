import SpriteKit

class MannaCoordinator {
    static var shared: MannaCoordinator!

    static let cMorsels = 750
    var cMorsels = 0
    weak var mannaSpriteFactory: SpriteFactory?

    private let mannaq = DispatchQueue(
        label: "arkonia.mannaq", qos: .utility, attributes: .concurrent,
        target: DispatchQueue.global()
    )

    init(spriteFactory: SpriteFactory) {
        mannaSpriteFactory = spriteFactory
        mannaq.async { self.populate() }
    }

    func populate() {
        if cMorsels >= MannaCoordinator.cMorsels {
            return
        }

        Lockable<SKSpriteNode>().lock({ () -> SKSpriteNode in
            let sprite = self.mannaSpriteFactory!.mannaHangar.makeSprite()
            Arkon.arkonsPortal!.addChild(sprite)
            return sprite
        }, { sprite in
            let manna = Manna(sprite)

            sprite.userData = [SpriteUserDataKey.manna: manna]

            self.plant(manna)
        })
    }
}

extension MannaCoordinator {
    func beEaten(_ sprite: SKSpriteNode) {
        Grid.getRandomPoint(background: Arkon.arkonsPortal!) { randomPoint in
            randomPoint.gridlet.contents = .manna
            randomPoint.gridlet.sprite = sprite
            self.recycle(sprite.manna, at: randomPoint)
        }
    }

    private func recycle(_ manna: Manna, at randomPoint: Grid.RandomGridPoint) {
        mannaq.async { self.recycle_(manna, at: randomPoint) }
    }

    private func recycle_(_ manna: Manna, at randomPoint: Grid.RandomGridPoint) {
        let recycleAction = MannaCoordinator.getRecycleAction(
            for: manna, at: randomPoint
        )

        manna.sprite.run(recycleAction)
    }
}

extension MannaCoordinator {
    private func plant(_ manna: Manna) { setPosition_(manna) }

    private func setPosition_(_ manna: Manna) {
        Lockable<Void>().lock({
            let randomPoint = Grid.getRandomPoint_(background: Arkon.arkonsPortal!)
            MannaCoordinator.plantSingleManna(manna, at: randomPoint)
        }, {
            self.finishPlanting(manna)
        })
    }

    private func finishPlanting(_ manna: Manna) {
        manna.sprite.setScale(0.1)
        manna.sprite.color = .orange
        manna.sprite.colorBlendFactor = Manna.colorBlendMinimum
        manna.sprite.run(MannaCoordinator.colorAction)

        cMorsels += 1

        mannaq.async(execute: populate)
    }

    static private func plantSingleManna(
        _ manna: Manna, at randomPoint: Grid.RandomGridPoint
    ) {
        let gridlet = randomPoint.gridlet
        gridlet.contents = .manna
        gridlet.sprite = manna.sprite

        manna.sprite.position = randomPoint.cgPoint
    }
}

extension MannaCoordinator {
    private static let colorAction = SKAction.colorize(
        with: .orange, colorBlendFactor: 1.0,
        duration: Manna.fullGrowthDurationSeconds
    )

    private static func getWaitAction(_ rebloomDelay: TimeInterval) -> SKAction {
        return SKAction.wait(forDuration: rebloomDelay)
    }

    private static func getRecycleAction(
        for manna: Manna, at randomPoint: Grid.RandomGridPoint
    ) -> SKAction {
        let fadeOut = SKAction.fadeOut(withDuration: 0.001)
        let wait = MannaCoordinator.getWaitAction(manna.rebloomDelay)
        let death = SKAction.sequence([fadeOut, wait])

        let replant = SKAction.run {
            plantSingleManna(manna, at: randomPoint)
        }

        let fadeIn = SKAction.fadeIn(withDuration: 0.001)
        let rebirth = SKAction.sequence([fadeIn, colorAction])

        return SKAction.sequence([death, replant, rebirth])
    }
}
