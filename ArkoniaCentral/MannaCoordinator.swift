import SpriteKit

class MannaCoordinator {
    static var shared: MannaCoordinator!

    static let colorAction = SKAction.colorize(
        with: .blue, colorBlendFactor: Manna.colorBlendMaximum,
        duration: Manna.fullGrowthDurationSeconds
    )

    static let fadeInAction = SKAction.fadeIn(withDuration: 0.001)
    static let fadeOutAction = SKAction.fadeOut(withDuration: 0.001)

    static let cMorsels = 1000
    var cMorsels = 0
    weak var mannaSpriteFactory: SpriteFactory?

    init() {
        mannaSpriteFactory = Wangkhi.spriteFactory
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

        let action = SKAction.run { [unowned self] in
            let sprite = self.mannaSpriteFactory!.mannaHangar.makeSprite()
            GriddleScene.arkonsPortal!.addChild(sprite)

            manna = Manna(sprite)
            sprite.userData = [SpriteUserDataKey.manna: manna!]

            self.cMorsels += 1
        }

        GriddleScene.arkonsPortal.run(action) { [unowned self] in
            self.plant(manna)
            self.populate()
        }
    }
}

extension MannaCoordinator {
    func beEaten(_ sprite: SKSpriteNode) {
        Grid.shared.serialQueue.async(flags: .barrier) { [unowned self] in
            let gridCell = GridCell.getRandomEmptyCell()
            gridCell.contents = .manna
            gridCell.sprite = sprite

            guard let manna = sprite.getManna() else { fatalError() }
            manna.sprite.alpha = 0
            self.plant(manna)
        }
    }
}

extension MannaCoordinator {
    private func plant_(_ manna: Manna) {
        let gridCell = GridCell.getRandomEmptyCell()

        gridCell.contents = .manna
        gridCell.sprite = manna.sprite
        guard manna.sprite.userData?[SpriteUserDataKey.manna] is Manna else { fatalError() }

        if let sp = gridCell.randomScenePosition {
            manna.sprite.position = sp
        } else {
            manna.sprite.position = gridCell.scenePosition
        }

        manna.sprite.alpha = 0
        manna.sprite.setScale(0.14)
        manna.sprite.colorBlendFactor = Manna.colorBlendMinimum

        bloom(manna)
    }

    func plant(_ manna: Manna) {
        Grid.shared.serialQueue.async(flags: .barrier) { [unowned self] in self.plant_(manna) }
    }
}
