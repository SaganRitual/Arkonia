import SpriteKit

class MannaCoordinator {
    static var shared: MannaCoordinator!

    static let cMorsels = 1000
    var cMorsels = 0
    weak var mannaSpriteFactory: SpriteFactory?

    static func lock<T>(
        _ execute: Sync.Lockable<T>.LockExecute? = nil,
        _ userOnComplete: Sync.Lockable<T>.LockOnComplete? = nil,
        _ completionMode: Sync.CompletionMode = .concurrent
    ) {
        func debugEx() -> [T]? { print("Manna.barrier"); return execute?() }
        func debugOc(_ args: [T]?) { print("Manna.concurrent"); userOnComplete?(args) }

        Sync.Lockable<T>(Grid.lockQueue).lock(debugEx, debugOc, completionMode)
    }

    init() {
        mannaSpriteFactory = Wangkhi.spriteFactory
        Grid.lockQueue.async { self.populate() }
    }

    func populate() {
//        print("p1")
        if cMorsels >= MannaCoordinator.cMorsels { return }
//        print("p2")

        let action = SKAction.run {
//            print("p3")
            let sprite = self.mannaSpriteFactory!.mannaHangar.makeSprite()
            GriddleScene.arkonsPortal!.addChild(sprite)

            let manna = Manna(sprite)
            sprite.userData = [SpriteUserDataKey.manna: manna]
//            print("p4")
            self.plant(manna)
//            print("p5")
        }
//        print("p6")

        GriddleScene.arkonsPortal.run(action)
    }
}

extension MannaCoordinator {
    func beEaten(_ sprite: SKSpriteNode) {
        Grid.lock({ () -> [Gridlet]? in
            let grs = Gridlet.getRandomGridlet_()
            return grs
        }, { grs in
            guard let gridlets = grs else { fatalError() }
            let gridlet = gridlets[0]

            gridlet.contents = .manna
            gridlet.sprite = sprite

            let manna = Manna.getManna(from: sprite)
            self.recycle(manna, at: gridlet)
        },
           .continueBarrier
        )
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
        Grid.lock({ () -> [Gridlet]? in
            let gridlet = Gridlet.getRandomGridlet_()
//            print("pl1")
            MannaCoordinator.plantSingleManna(manna, at: gridlet![0])
            return nil
        }, {
            _ in
//            print("pl2")
            self.finishPlanting(manna)
        }, .continueBarrier)
    }

    private func finishPlanting(_ manna: Manna) {
//        print("finishPlanting_")
        manna.sprite.alpha = 0
        manna.sprite.setScale(0.1)
        manna.sprite.color = .orange
        manna.sprite.colorBlendFactor = Manna.colorBlendMinimum

        let run = SKAction.run {}// print("in fp action") }

        let sequence = SKAction.sequence([
            run,
            MannaCoordinator.MannaRecycler.fadeInAction
        ])

        manna.sprite.run(sequence) {
//            print("sprite.run")
            self.cMorsels += 1
            Grid.lockQueue.async(execute: self.populate)

            manna.sprite.run(
                MannaCoordinator.MannaRecycler.colorAction
            )
        }
    }

    static func plantSingleManna(_ manna: Manna, at gridlet: Gridlet) {
        gridlet.contents = .manna
        gridlet.sprite = manna.sprite

        if let sp = gridlet.randomScenePosition {
            manna.sprite.position = sp
        } else {
            manna.sprite.position = gridlet.scenePosition
        }
    }
}

extension MannaCoordinator {
}
