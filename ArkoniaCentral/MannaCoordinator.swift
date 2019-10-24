import SpriteKit

class MannaCoordinator {
    static var shared: MannaCoordinator!

    static let cMorsels = 750
    var cMorsels = 0
    weak var mannaSpriteFactory: SpriteFactory?

    static private let lockQueue = DispatchQueue(
        label: "arkonia.mannaq", qos: .utility, attributes: .concurrent,
        target: DispatchQueue.global()
    )

    static func lock<T>(
        _ execute: Dispatch.Lockable<T>.LockExecute? = nil,
        _ userOnComplete: Dispatch.Lockable<T>.LockOnComplete? = nil,
        _ completionMode: Dispatch.CompletionMode = .concurrent
    ) {
        func debugEx() -> [T]? { print("Manna.barrier"); return execute?() }
        func debugOc(_ args: [T]?) { print("Manna.concurrent"); userOnComplete?(args) }

        Dispatch.Lockable<T>(lockQueue).lock(
            debugEx, debugOc, completionMode
        )
    }

    init() {
        mannaSpriteFactory = ArkonFactory.spriteFactory
        MannaCoordinator.lockQueue.async { self.populate() }
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
        Gridlet.getRandomGridlet { grs in
            guard let gridlets = grs else { fatalError() }
            let gridlet = gridlets[0]

            gridlet.contents = .manna
            gridlet.sprite = sprite

            let manna = Manna.getManna(from: sprite)
            self.recycle(manna, at: gridlet)
        }
    }

    private func recycle(_ manna: Manna, at gridlet: Gridlet) {
        MannaCoordinator.lockQueue.async { self.recycle_(manna, at: gridlet) }
    }

    private func recycle_(_ manna: Manna, at gridlet: Gridlet) {
        let recycleAction = MannaCoordinator.getRecycleAction(
            for: manna, at: gridlet
        )

        manna.sprite.run(recycleAction)
    }
}

extension MannaCoordinator {
    private func plant(_ manna: Manna) { setPosition_(manna) }

    private func setPosition_(_ manna: Manna) {
        Grid.lock({ () -> [Gridlet]? in
            let gridlet = Gridlet.getRandomGridlet_()
            MannaCoordinator.plantSingleManna(manna, at: gridlet![0])
            return nil
        }, {
            _ in self.finishPlanting(manna)
        }, .concurrent)
    }

    private func finishPlanting(_ manna: Manna) {
        manna.sprite.setScale(0.1)
        manna.sprite.color = .orange
        manna.sprite.colorBlendFactor = Manna.colorBlendMinimum
        manna.sprite.run(MannaCoordinator.colorAction)

        cMorsels += 1

        MannaCoordinator.lockQueue.async(execute: populate)
    }

    static private func plantSingleManna(
        _ manna: Manna, at gridlet: Gridlet
    ) {
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
    private static let colorAction = SKAction.colorize(
        with: .orange, colorBlendFactor: 1.0,
        duration: Manna.fullGrowthDurationSeconds
    )

    private static func getWaitAction(_ rebloomDelay: TimeInterval) -> SKAction {
        return SKAction.wait(forDuration: rebloomDelay)
    }

    private static func getRecycleAction(
        for manna: Manna, at gridlet: Gridlet
    ) -> SKAction {
        let fadeOut = SKAction.fadeOut(withDuration: 0.001)
        let wait = MannaCoordinator.getWaitAction(manna.rebloomDelay)
        let death = SKAction.sequence([fadeOut, wait])

        let replant = SKAction.run {
            plantSingleManna(manna, at: gridlet)
        }

        let fadeIn = SKAction.fadeIn(withDuration: 0.001)
        let rebirth = SKAction.sequence([fadeIn, colorAction])

        return SKAction.sequence([death, replant, rebirth])
    }
}
