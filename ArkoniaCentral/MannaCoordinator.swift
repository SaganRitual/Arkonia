import SpriteKit

class MannaCoordinator {
    static var shared: MannaCoordinator!

    static let cMorsels = 1000
    var cMorsels = 0
    weak var mannaSpriteFactory: SpriteFactory?

    init() {
        mannaSpriteFactory = Wangkhi.spriteFactory
        populate()
    }

    func getPopulateAction() -> SKAction {
        return SKAction.run(self.populate_)
    }

    func populate_() {
        let sprite = self.mannaSpriteFactory!.mannaHangar.makeSprite()
        GriddleScene.arkonsPortal!.addChild(sprite)

        let manna = Manna(sprite)
        sprite.userData = [SpriteUserDataKey.manna: manna]
        self.plant(manna)
    }

    func populate() {
        if cMorsels >= MannaCoordinator.cMorsels { return }

        let action = getPopulateAction()
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
    private func plant(_ manna: Manna) {
        Grid.shared.serialQueue.sync {
            let gridlet = Gridlet.getRandomGridlet_()
            MannaCoordinator.plantSingleManna_(manna, at: gridlet)
            self.finishPlanting(manna)
        }
    }

    private func getFinishPlantingAction() -> SKAction {
        return SKAction.sequence([
            MannaCoordinator.MannaRecycler.fadeInAction,
            SKAction.run({ self.cMorsels += 1 }),
            getPopulateAction(),
            MannaCoordinator.MannaRecycler.colorAction
        ])
    }

    private func finishPlanting(_ manna: Manna) {
//        print("finishPlanting_")
        manna.sprite.alpha = 0
        manna.sprite.setScale(0.1)
        manna.sprite.color = .orange
        manna.sprite.colorBlendFactor = Manna.colorBlendMinimum

        let sequence = getFinishPlantingAction()

        manna.sprite.run(sequence)
    }

    static func plantSingleManna_(_ manna: Manna, at gridlet: Gridlet) {
        gridlet.contents = .manna
        gridlet.sprite = manna.sprite

        if let sp = gridlet.randomScenePosition {
            manna.sprite.position = sp
        } else {
            manna.sprite.position = gridlet.scenePosition
        }
    }

    static func plantSingleManna(_ manna: Manna, at gridlet: Gridlet) {
        Grid.shared.serialQueue.sync { plantSingleManna_(manna, at: gridlet) }
    }
}
