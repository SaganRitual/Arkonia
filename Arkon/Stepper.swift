import SpriteKit

let MainDispatchQueue = DispatchQueue(
    label: "ak.dispatch.q", attributes: .concurrent, target: DispatchQueue.global()
)

class Stepper: GridPlantableArkon {
    let fishday: Fishday
    let metabolism: Metabolism
    let net: Net
    let netDisplay: NetDisplay?
    let nose: SKSpriteNode
    let sensorPad: SensorPad
    let thorax: SKSpriteNode
    let tooth: SKSpriteNode

    var babyBumpIsShowing = false
    var canSpawn = false
    var cFoodHits = 0
    var cJumps = 0
    var cOffspring = 0
    var currentTime: Int = 0
    var currentEntropyPerJoule: Double = 0
    var jumpSpec: JumpSpec?
    var jumpSpeed = 0.0
    var previousShiftOffset = AKPoint.zero

    var name: ArkonName { fishday.name }

    init(_ embryo: ArkonEmbryo) {
        self.fishday = embryo.fishday!
        self.metabolism = embryo.metabolism!
        self.net = embryo.net!
        self.netDisplay = embryo.netDisplay
        self.nose = embryo.noseSprite!
        self.thorax = embryo.thoraxSprite!
        self.tooth = embryo.toothSprite!

        self.sensorPad = embryo.sensorPad!

        thorax.position = sensorPad.centerCellScenePosition!
        thorax.color = net.isCloneOfParent ? .green : .white
        nose.color = .blue
    }
}
