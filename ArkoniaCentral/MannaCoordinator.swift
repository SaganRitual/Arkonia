import SpriteKit

class MannaCoordinator {
    static var shared: MannaCoordinator!

    static let cMorsels = 500
    var cMorsels = 0
    weak var mannaSpriteFactory: SpriteFactory?

    init() {
        mannaSpriteFactory = Wangkhi.spriteFactory
        populate()
    }

    private func bloom() {
        let action = SKAction.group([
            MannaCoordinator.MannaRecycler.fadeInAction,
            MannaCoordinator.MannaRecycler.colorAction
        ])

        GriddleScene.arkonsPortal.run(action)
    }

    func makeNewMannaAction() -> SKAction {
        return SKAction.run {
            let sprite = self.mannaSpriteFactory!.mannaHangar.makeSprite()
            GriddleScene.arkonsPortal!.addChild(sprite)

            let manna = Manna(sprite)
            sprite.userData = [SpriteUserDataKey.manna: manna]

            self.cMorsels += 1
        }
    }

    func populate() {
        if cMorsels >= MannaCoordinator.cMorsels { return }
        let action = makeNewMannaAction()
        GriddleScene.arkonsPortal.run(action)
    }
}

extension MannaCoordinator {
    func beEaten(_ sprite: SKSpriteNode) {
        var gridlet: Gridlet?

        Gridlet.getRandomGridlet {
            gridlet = $0
            gridlet!.contents = .manna
            gridlet!.sprite = sprite
        }

        let manna = Manna.getManna(from: sprite)
        self.recycle(manna, at: gridlet!)
    }

    private func recycle(_ manna: Manna, at gridlet: Gridlet) {
        manna.sprite.userData!["recycler"] =
            MannaCoordinator.MannaRecycler(manna, gridlet, self)

        ((manna.sprite.userData!["recycler"])! as?
            MannaCoordinator.MannaRecycler)!.go()
    }
}

extension MannaCoordinator {
    private func plant_(_ manna: Manna) {
        let gridlet = Gridlet.getRandomGridlet_()

        gridlet.contents = .manna
        gridlet.sprite = manna.sprite

        if let sp = gridlet.randomScenePosition {
            manna.sprite.position = sp
        } else {
            manna.sprite.position = gridlet.scenePosition
        }

        manna.sprite.alpha = 0
        manna.sprite.setScale(0.1)
        manna.sprite.color = .orange
        manna.sprite.colorBlendFactor = Manna.colorBlendMinimum

        bloom()
    }

    private func plant(_ manna: Manna) {
        Grid.shared.serialQueue.sync { plant_(manna) }
    }
}
