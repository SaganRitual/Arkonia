import Foundation
import SpriteKit

class Arkon {
    let birthday: TimeInterval
    var destructAction: SKAction!
    let fishNumber: Int
    let fNet: FNet
    var foodPosition = CGPoint.zero
    let genome: Genome
    var hasGivenBirth = false
    var health = 5.0
    var isAlive = false
    var kNet: KNet!
    var motorOutputs: MotorOutputs!
    var portal: SKSpriteNode!
    let signalDriver: KSignalDriver
    var sprite: SKSpriteNode!
    var tickAction: SKAction!

    var isHealthy: Bool { return health > 0 }

    var isInBounds: Bool {
        let relativeToPortal = portal.convert(sprite.frame.origin, to: portal.parent!)

        let w = sprite.size.width * portal.xScale
        let h = sprite.size.height * portal.yScale
        let scaledSize = CGSize(width: w, height: h)

        let arkonRectangle = CGRect(origin: relativeToPortal, size: scaledSize)

        // Remember: get the scene frame rather than the portal frame because
        // that's how big the portal's children think the portal is. We can't
        // use the portal's frame, because it is doing its own thing due to scaling.
        return portal.frame.contains(arkonRectangle)
    }

    var myAge: TimeInterval { return Display.shared.currentTime - self.birthday }

    init?(genome: Genome, fNet: FNet, portal: SKSpriteNode) {
        self.fishNumber = ArkonCentralDark.selectionControls.theFishNumber
        ArkonCentralDark.selectionControls.theFishNumber += 1

        self.birthday = Display.shared.currentTime

        self.portal = portal

        self.genome = genome
        self.fNet = fNet
        self.signalDriver = KSignalDriver(idNumber: self.fishNumber, fNet: fNet)

        let arkonSurvived = signalDriver.drive(
            sensoryInputs: Array.init(
                repeating: 0, count: ArkonCentralDark.selectionControls.cSenseNeurons
            )
        )

        // Dark parts all set up; SpriteKit will add a sprite and
        // launch on the next display cycle, unless, of course, we didn't
        // survive the test signal.

        if !arkonSurvived { return nil }
    }

    deinit {
//        print("Arkon(\(fishNumber)) deinit")
        func getArkon(for sprite: SKNode) -> Arkon? {
            return (((sprite as? SKSpriteNode)?.userData?["Arkon"]) as? Arkon)
        }

        func getAge(_ node: SKNode) -> TimeInterval {
            guard let arkon = getArkon(for: node) else { return 0 }
            return (arkon.birthday > 0) ? arkon.myAge : 0
        }

        let spriteOfOldestLivingArkon = portal.children.max { lhs, rhs in
            return getAge(lhs) < getAge(rhs)
        }

        DebugPortal.shared.specimens[.currentOldest]?.value = Int(getAge(spriteOfOldestLivingArkon!))
        self.sprite?.removeFromParent()

        // Decrement living count only if I am a living arkon, that is,
        // if I survived birth.
        if self.isAlive {
            World.shared.arkonery.cLivingArkons -= 1
            self.isAlive = false // Tidiness/superstition
        }
    }
}

// MARK: Guts

extension Arkon {

    func apoptosize() {
        sprite.removeAllActions()
        sprite.run(destructAction)
        sprite = nil
    }
}
