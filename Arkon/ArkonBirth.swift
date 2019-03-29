import Foundation
import SpriteKit

extension SKSpriteNode {
    var arkon: Arkon? {
        get { return getUserData(UserDataKey.arkon) }
        set { setUserData(key: UserDataKey.arkon, to: newValue) }
    }
}

extension Arkon {

    static private func attachSenses(_ sprite: SKSpriteNode, _ senses: SKPhysicsBody) {
        let snapPoint =
            PortalServer.shared.arkonsPortal.get().convert(sprite.position, to: Display.shared.scene!)

        let snap = SKPhysicsJointPin.joint(
            withBodyA: sprite.physicsBody!, bodyB: senses, anchor: snapPoint
        )

        Display.shared.scene!.physicsWorld.add(snap)
    }

    func launch(sprite: Karamba) {
        self.sprite = sprite    // The new-style Karamba sprite

        self.apoptosizeAction = SKAction.sequence([
            SKAction.run { [weak self] in
                print("fish \(?!self?.fishNumber) apoptosizing; cycle \(Display.displayCycle)")
                self?.sprite.physicsBody = nil
                (self?.sprite.children[0] as? SKSpriteNode)?.physicsBody = nil
                self?.sprite?.userData?[SKSpriteNode.UserDataKey.arkon] = nil
            }, SKAction.removeFromParent()
        ])

        postPartum(relievedArkonFishNumber: self.parentFishNumber)

        /*
         // So offspring won't come into existence on top of their
         // parent, which causes them to bounce around, which might
         // be ok, or not, I don't know. But when we run the following,
         // Everything gets really crazy, way more than without it.
         // Maybe we need to give the birthing mother a repeller field
         // to clear some space for her incoming baby. Come back to it.
         //
        if let parent = ArkonFactory.shared.getArkon(for: self.parentFishNumber) {
            let Θ = CGFloat.random(in: 0..<360)
            let r = 2.1 * sqrt(
                parent.sprite.frame.width * parent.sprite.frame.width +
                parent.sprite.frame.height * parent.sprite.frame.height
            )

            self.sprite.position = CGPoint(x: r * cos(Θ), y: r * sin(Θ))
        }
        */

        World.shared.populationChanged = true

        self.sprite.alpha = 1
        status.isAlive = true

        sprite.setScale(ArkonFactory.scale)
        sprite.physicsBody!.mass = 1
    }

    func postPartum(relievedArkonFishNumber: Int?) {
        guard let r = relievedArkonFishNumber else { return }
        guard let arkon = World.shared.population.getArkon(for: r) else { return }

        arkon.status.cOffspring += 1
        arkon.sprite.color = {
            switch arkon.status.cOffspring {
            case 0..<5: return .green
            case 5..<10: return .purple
            case 10..<15: return .magenta
            default: return .orange
            }
        }()

        arkon.sprite.color = arkon.status.cOffspring > 5 ? .purple : .green
    }
}
