import SpriteKit

extension Manna {
    class Garden {
        var cMorsels = 0
        var manna: Manna?
        unowned let mannaSpriteHangar = SpriteFactory.shared.mannaHangar
    }
}

extension Manna.Garden {

    static let bloomAction = SKAction.group([
        MannaCoordinator.fadeInAction,
        MannaCoordinator.colorAction
    ])

    func beEaten(_ sprite: SKSpriteNode) {
        guard let manna = sprite.getManna() else { fatalError() }
        plant(manna)
    }

    private func plant(_ manna: Manna) {
        GridCell.lockRandomEmptyCell(ownerName: manna.sprite.name!) { hk in
            guard let hotKey = hk else { fatalError() }
            hotKey.contents = .manna
            hotKey.sprite = manna.sprite
            guard manna.sprite.userData?[SpriteUserDataKey.manna] is Manna else { fatalError() }

            manna.sprite.position =
                hotKey.randomScenePosition ?? hotKey.scenePosition

            manna.sprite.alpha = 0
            manna.sprite.setScale(0.14 / Arkonia.masterScale)
            manna.sprite.colorBlendFactor = Manna.colorBlendMinimum

            manna.sprite.run(Manna.Garden.bloomAction)
        }
    }

    private func createNewManna() -> Manna? {
        if cMorsels >= MannaCoordinator.cMorsels { return nil }

        let sprite = self.mannaSpriteHangar.makeSprite("manna-\(cMorsels)")

        GriddleScene.arkonsPortal!.addChild(sprite)

        self.manna = Manna(sprite)
        sprite.userData![SpriteUserDataKey.manna] = self.manna!

        self.cMorsels += 1
        return self.manna
    }

    func populate() {
        let a = SKAction.run {
            guard let m = self.createNewManna() else { return }
            self.plant(m)
            self.manna = m
        }

        GriddleScene.shared.run(a) {
            if self.cMorsels < MannaCoordinator.cMorsels { self.populate() }
        }
    }
}

class MannaCoordinator {
    static var shared: MannaCoordinator!

    static let colorAction = SKAction.colorize(
        with: .blue, colorBlendFactor: Manna.colorBlendMaximum,
        duration: Manna.fullGrowthDurationSeconds
    )

    static let fadeInAction = SKAction.fadeIn(withDuration: 1)
    static let fadeOutAction = SKAction.fadeOut(withDuration: 0.001)

    static let cMorsels = 1250 * Int(Arkonia.masterScale)
}
