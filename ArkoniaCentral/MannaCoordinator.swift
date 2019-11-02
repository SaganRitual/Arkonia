import SpriteKit

class MannaCoordinator {
    static var shared: MannaCoordinator!

    static let cMorsels = 1000
    var cMorsels = 0
    weak var mannaSpriteFactory: SpriteFactory?

    init() {
        mannaSpriteFactory = Wangkhi.spriteFactory
        self.populate()
    }

    func populate() {
        if cMorsels >= MannaCoordinator.cMorsels { return }

        let action = SKAction.run {
            let sprite = self.mannaSpriteFactory!.mannaHangar.makeSprite()
            GriddleScene.arkonsPortal!.addChild(sprite)

            let manna = Manna(sprite)
            sprite.userData = [SpriteUserDataKey.manna: manna]
            self.plant(manna)
        }

        GriddleScene.arkonsPortal.run(action)
    }
}

extension MannaCoordinator {
    func beEaten(_ sprite: SKSpriteNode) {
        let gridlet = Gridlet.getRandomGridlet()

        gridlet.contents = .manna
        gridlet.sprite = sprite

        let manna = Manna.getManna(from: sprite)
        self.recycle(manna, at: gridlet)
    }

    private func recycle(_ manna: Manna, at gridlet: Gridlet) {
        manna.sprite.userData!["recycler"] =
            MannaCoordinator.MannaRecycler(manna, gridlet, self)

        ((manna.sprite.userData!["recycler"])! as?
            MannaCoordinator.MannaRecycler)!.go()
    }
}

extension MannaCoordinator {
    private func plant(_ manna: Manna) {
        let gridlet = Gridlet.getRandomGridlet()
        MannaCoordinator.plantSingleManna(manna, at: gridlet)
        self.finishPlanting(manna)
    }

    private func finishPlanting(_ manna: Manna) {
        manna.sprite.alpha = 0
        manna.sprite.setScale(0.1)
        manna.sprite.color = .orange
        manna.sprite.colorBlendFactor = Manna.colorBlendMinimum

        let run = SKAction.run {}// print("in fp action") }

        let sequence = SKAction.sequence([
            run,
            MannaCoordinator.MannaRecycler.fadeInAction
        ])

        manna.sprite.run(sequence) { [unowned self] in
            self.cMorsels += 1
            self.populate()

            manna.sprite.run(
                MannaCoordinator.MannaRecycler.colorAction
            )
        }
    }

    static func plantSingleManna(_ manna: Manna, at gridlet: Gridlet) {
        Grid.shared.serialQueue.sync {
            gridlet.contents = .manna
            gridlet.sprite = manna.sprite

            if let sp = gridlet.randomScenePosition {
                manna.sprite.position = sp
            } else {
                manna.sprite.position = gridlet.scenePosition
            }
        }
    }
}
