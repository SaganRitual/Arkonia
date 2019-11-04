import SpriteKit

class MannaCoordinator {
    static var shared: MannaCoordinator!

    static let colorAction = SKAction.colorize(
        with: .blue, colorBlendFactor: Manna.colorBlendMinimum,
        duration: Manna.fullGrowthDurationSeconds
    )

    static let fadeInAction = SKAction.fadeIn(withDuration: 0.001)
    static let fadeOutAction = SKAction.fadeOut(withDuration: 0.001)

    static let cMorsels = 500
    var cMorsels = 0
    weak var mannaSpriteFactory: SpriteFactory?

    init() {
        mannaSpriteFactory = Wangkhi.spriteFactory
        populate()
    }

    private func bloom(_ manna: Manna) {
        let action = SKAction.group([
            MannaCoordinator.fadeInAction,
            MannaCoordinator.colorAction
        ])

        manna.sprite.run(action)
    }

    func populate() {
        if cMorsels >= MannaCoordinator.cMorsels { return }

        var manna: Manna!

        let action = SKAction.run {
            let sprite = self.mannaSpriteFactory!.mannaHangar.makeSprite()
            GriddleScene.arkonsPortal!.addChild(sprite)

            manna = Manna(sprite)
            sprite.userData = [SpriteUserDataKey.manna: manna!]

            self.cMorsels += 1
        }

        GriddleScene.arkonsPortal.run(action) {
            self.plant(manna)
            self.populate()
        }
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
        manna.sprite.alpha = 0
        plant(manna)
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
        manna.sprite.color = .green
        manna.sprite.colorBlendFactor = Manna.colorBlendMinimum

        bloom(manna)
    }

    func plant(_ manna: Manna) {
        Grid.shared.serialQueue.async { self.plant_(manna) }
    }
}
